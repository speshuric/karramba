#!/usr/bin/bash
# author v0rn: https://github.com/v0rn/ansible-arch/blob/master/create_arch_iso.sh

RED='\033[0;31m'
NC='\033[0m' # No Color
GRN='\033[1;32m'

function log() {
  echo -e "${GRN}$1${NC}"
}
function err() {
  echo -e "${RED}$1${NC}"
  exit 1
}
function check_size() {
  avail=$(df --output=avail $1 | tail -n 1)
  local newsize=4G
  local minsize=1048576
  if [ ${avail} -lt ${minsize} ]; then
    log "$1 is now ${avail} - upsiged to ${newsize}"
    mount -o remount,size=${newsize} /run/archiso/cowspace
  fi
}

if [ ${UID} != 0 ]; then
  err "$0 must be run as root"
  exit 1
fi

# For details read https://wiki.archlinux.org/index.php/Archiso

# Set parameters

# NOTES:
# - you can hardcode passwords here, but usually it is not needed with ansible installation,
#   ssh connection is established by _key_, not password
# - If you want shorter/longer password, choose length divided by 3 (9, 12, 15... 30, 33),
#   because base64 convert every 3 bytes to 4 characters

# generate users and passwords:
rootpassword=$(openssl rand -base64 15)
ansiblepassword=$(openssl rand -base64 15)
ansibleuser=ansible_install
ansiblehostname=ansiblearchiso

log "Prepare installation package"
pacman -Sy archiso --noconfirm

# Make archisodir with mktemp:
archisodir=$(mktemp -d -t archiso_XXXXX --tmpdir="$HOME")

bootentrydir="${archisodir}/efiboot/loader/entries"
bootentrycd="${bootentrydir}/archiso-x86_64-cd.conf"
bootentryusb="${bootentrydir}/archiso-x86_64-usb.conf"

archisosource="/usr/share/archiso/configs/releng"
archisodir_out="${archisodir}/out"
airootfs="${archisodir}/airootfs"

log "Prepare installation directory ${archisodir}"
# Create directory
mkdir -p ${archisodir}
mkdir -p ${archisodir_out}
mkdir -p ${airootfs}/etc/skel/.ssh
mkdir -p ${airootfs}/etc/ssh
mkdir -p ${airootfs}/etc/pacman.d

check_size ${archisodir}

# Copy archiso contents to directory
cp -r ${archisosource}/* ${archisodir}

# Add console device
for i in {${bootentrycd},${bootentryusb}}; do
  sed -i '/^options/ s/$/ console=ttyS0/' $i
done

# generate ssh keys with empty passphrase
ssh-keygen -q -N "" -f ${archisodir}/out/${ansibleuser}_key
ssh-keygen -q -N "" -t dsa -f ${archisodir}/out/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa -f ${archisodir}/out/ssh_host_rsa_key
ssh-keygen -q -N "" -t ecdsa -f ${archisodir}/out/ssh_host_ecdsa_key
ssh-keygen -q -N "" -t ed25519 -f ${archisodir}/out/ssh_host_ed25519_key

# put host's keys
cp ${archisodir}/out/ssh_host_* ${archisodir}/airootfs/etc/ssh/
# put ansibleuser's public key to skeleton
cp ${archisodir}/out/${ansibleuser}_key.pub ${airootfs}/etc/skel/.ssh/authorized_keys
chmod u=rw,go= ~/.ssh/${airootfs}/etc/skel/.ssh/authorized_keys

# NOTES:

customize_airootfs=${archisodir}/airootfs/root/customize_airootfs.sh

function add_customize_airootfs() {
  echo $1 >>${customize_airootfs}
}

# add ansible user, set password for root and ansible
add_customize_airootfs "echo root:${rootpassword} | chpasswd"
add_customize_airootfs "! id ${ansibleuser} && useradd -m -g users -G wheel -s /bin/zsh ${ansibleuser}"
add_customize_airootfs "echo ${ansibleuser}:${ansiblepassword} | chpasswd"
# add_customize_airootfs "ls /home/"

# grant sudo to ansible user through group %wheel:
# since password is random and user ansibleuser is not used after installation,
# allow sudo without password in our ISO
add_customize_airootfs "sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers"
# following line enforce using password
#add_customize_airootfs "sed -i '/%wheel ALL=(ALL) ALL/s/^#//' /etc/sudoers"
# check suoers
add_customize_airootfs "! (visudo -c -f /etc/sudoers) && echo \"sudoers is not correct\""

# copy passwords to out dir
echo "${ansibleuser}:$ansiblepassword" >>${archisodir}/out/passwords
echo "root:${rootpassword}" >>${archisodir}/out/passwords

# remove autologon
add_customize_airootfs "rm /etc/systemd/system/getty@tty1.service.d/autologin.conf"

# Enable sshd.service
add_customize_airootfs "systemctl enable sshd.service"

# Diasble root in SSH
add_customize_airootfs "sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config"

# set /etc/hostname"
add_customize_airootfs "echo ${ansiblehostname} > /etc/hostname"

# WAT???: add_customize_airootfs "sed -i '/APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL%' "

# If using the socket service, you will need to edit the unit file
# if you want it to listen on a port other than the default 22:
# https://wiki.archlinux.org/index.php/OpenSSH

# Add packages
packages=${archisodir}/packages.x86_64
echo "git" >>${packages}
echo "reflector" >>${packages}
echo "ansible" >>${packages}

# Copy mirrorlist to /root
cp /etc/pacman.d/mirrorlist ${archisodir}/airootfs/etc/pacman.d/mirrorlist

# syslinux: Exit the menu system immediately unless
# either the Shift or the Alt key is pressed, or Caps Lock or Scroll Lock is set.
echo "MENU SHIFTKEY" >>${archisodir}/syslinux/archiso_head.cfg

log "Build image"
cd ${archisodir}
./build.sh -v -N ${ansiblehostname}

log "Arch installation ISO created in ${archisodir}/out/"
