#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

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

umount ${MNT}/usr/local
umount ${MNT}/opt
umount ${MNT}/srv
umount ${MNT}/tmp
umount ${MNT}/root
umount ${MNT}/var
umount ${MNT}/boot
umount ${MNT}/home

umount ${MNT}




