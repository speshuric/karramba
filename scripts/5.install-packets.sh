#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi


MNT=/tmp/mnt

arch_chroot() { #{{{
  arch-chroot ${MNT} /bin/bash -c "${1}"
}
#}}}

pacman -Sy archlinux-keyring
pacstrap ${MNT} base linux-headers base-devel parted btrfs-progs f2fs-tools net-tools

# arch-chroot ${MNT}

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

