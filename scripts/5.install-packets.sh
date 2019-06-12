#!/usr/bin/env bash

# constant part
RED='\033[0;31m'
NC='\033[0m' # No Color
GRN='\033[1;32m'

function log {
    echo -e "${GRN}$1${NC}"
}
function err {
    echo -e "${RED}$1${NC}"
    exit 1
}

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi


MNT=/tmp/mnt

arch_chroot() { #{{{
  arch-chroot ${MNT} /bin/bash -c "${1}"
}
#}}}

log "update keyring"
pacman -Sy archlinux-keyring
log "bootstrap"
pacstrap ${MNT} base linux-headers base-devel parted btrfs-progs f2fs-tools net-tools

log "set time zone"
#  print_title "TIMEZONE - https://wiki.archlinux.org/index.php/Timezone"
#  print_info "In an operating system the time (clock) is determined by four parts: Time value, Time standard, Time Zone, and DST (Daylight Saving Time if applicable)."
#  OPTION=n
#  while [[ $OPTION != y ]]; do
#    settimezone
#    read_input_text "Confirm timezone (${ZONE}/${SUBZONE})"
#  done
ZONE="Europe"
SUBZONE="Moscow"

arch_chroot "ln -sf /usr/share/zoneinfo/${ZONE}/${SUBZONE} /etc/localtime"
arch_chroot "sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf"
arch_chroot "sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf"
arch_chroot "echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf"
arch_chroot "systemctl enable systemd-timesyncd.service"
arch_chroot "hwclock --systohc --utc"

log "set locale"


arch_chroot "echo \"en_US.UTF-8 UTF-8\" > /etc/locale.gen"
arch_chroot "echo \"ru_RU.UTF-8 UTF-8\" >> /etc/locale.gen"
arch_chroot "locale-gen"

log "Указываем язык системы"
arch_chroot "echo LANG=en_US.UTF-8 > /etc/locale.conf"
arch_chroot "echo LC_TIME=ru_RU.UTF-8 >> /etc/locale.conf"

log "Вписываем KEYMAP=ru FONT=cyr-sun16"
arch_chroot "echo KEYMAP=ru >> /etc/vconsole.conf"
arch_chroot "echo FONT=cyr-sun16 >> /etc/vconsole.conf"
arch_chroot "echo myhostname >> /etc/hostname"

arch_chroot "mkinitcpio -p linux"