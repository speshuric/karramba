#!/usr/bin/bash
# author v0rn: https://github.com/v0rn/ansible-arch/blob/master/create_arch_iso.sh

if [ ${UID} != 0 ]; then
    echo "$0 must be run as root"
    exit 1
fi

# For details read https://wiki.archlinux.org/index.php/Archiso

# Prepare installation package
pacman -Sy archiso --noconfirm

# Make archisodir with mktemp:
archisodir=$(mktemp -d -t archiso_XXXXX)

bootentrydir="${archisodir}/efiboot/loader/entries"
bootentrycd="${bootentrydir}/archiso-x86_64-cd.conf"
bootentryusb="${bootentrydir}/archiso-x86_64-usb.conf"

archisosource="/usr/share/archiso/configs/releng"

# Create directory
mkdir ${archisodir}
mkdir ${archisodir}/out

# Copy archiso contents to directory
cp -r ${archisosource}/* ${archisodir}

# Add console device
for i in {${bootentrycd},${bootentryusb}}; do
    sed -i '/^options/ s/$/ console=ttyS0/' $i
done

# generate users and passwords:
rootpassword=$(openssl rand -base64 15)
ansiblepassword=$(openssl rand -base64 15)
ansibleuser=ansible_install
# generate ssh keys with empty passphrase
ssh-keygen -q -N "" -f            ${archisodir}/out/${ansibleuser}_key
ssh-keygen -q -N "" -t dsa     -f ${archisodir}/out/ssh_host_dsa_key
ssh-keygen -q -N "" -t rsa     -f ${archisodir}/out/ssh_host_rsa_key
ssh-keygen -q -N "" -t ecdsa   -f ${archisodir}/out/ssh_host_ecdsa_key
ssh-keygen -q -N "" -t ed25519 -f ${archisodir}/out/ssh_host_ed25519_key

mkdir -p ${archisodir}/airootfs/etc/ssh
cp ${archisodir}/out/ssh_host_* ${archisodir}/airootfs/etc/ssh/

# NOTES:
# - you can hardcode passwords here, but usually it is not needed with ansible installation
# - If you want shorter/longer password, choose length divided by 3 (9, 12, 15... 30, 33), 
#   because base64 convert every 3 bytes to 4 characters

customize_airootfs=${archisodir}/airootfs/root/customize_airootfs.sh

# add ansible user, set password for root and ansible
echo "! id ${ansibleuser} && useradd -m -g users -G wheel -s /bin/zsh ${ansibleuser}" >> ${customize_airootfs}
echo "echo ${ansibleuser}:${ansiblepassword} | chpasswd"                              >> ${customize_airootfs}
echo "echo root:${rootpassword} | chpasswd"                                           >> ${customize_airootfs}

# copy passwords to out dir
echo "${ansibleuser}:$ansiblepassword" >> ${archisodir}/out/passwords
echo "root:${rootpassword}"            >> ${archisodir}/out/passwords

# Enable sshd.socket
echo "systemctl enable sshd.socket" >> ${customize_airootfs}
# Diasble root in SSH
echo 'sed -e "s/^PermitRootLogin yes/#PermitRootLogin yes/" /etc/ssh/sshd_config' >> ${customize_airootfs}

# If using the socket service, you will need to edit the unit file 
# if you want it to listen on a port other than the default 22: 
# https://wiki.archlinux.org/index.php/OpenSSH

# Add packages
packages=${archisodir}/packages.x86_64
echo "git"       >> ${packages}
echo "reflector" >> ${packages}
echo "ansible"   >> ${packages}

# Copy mirrorlist to /root
cp /etc/pacman.d/mirrorlist ${archisodir}/airootfs/root/

# Build image
cd ${archisodir}
./build.sh -v

echo "Arch installation ISO created in ${archisodir}/out/"
