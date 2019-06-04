#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

HDD=sda
# - Затычка для MBR
BIOS_GRUB_PART=sda1
# - EFI Service Partition
ESP_PART=sda2
# - /boot Partition
BOOT_PART=sda3
# - swp Partition
ROOT_PART=sda4
# - root Partition
ROOT_PART=sda5
# - /home Partition
HOME_PART=sda6

MNT=/tmp/mnt

arch_chroot() { #{{{
  arch-chroot $MOUNTPOINT /bin/bash -c "${1}"
}
#}}}

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

#install base

#choose kernels
#CHOSEN_KERNELS=linux414 linux418 
#CHOSEN_AUR=yaourt base-devel 
#CHOSEN_KERNEL_MODULES=linux414-headers linux414-virtualbox-guest-modules linux418-headers linux418-virtualbox-guest-modules 


# manjaro-chroot /mnt "grub-install --target=i386-pc --recheck /dev/${HDD}"



