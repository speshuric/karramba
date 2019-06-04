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


mkdir -p ${MNT}           && mount                               /dev/${ROOT_PART} ${MNT}
mkdir -p ${MNT}/opt       && mount -o subvol=@/opt               /dev/${ROOT_PART} ${MNT}/opt
mkdir -p ${MNT}/srv       && mount -o subvol=@/srv               /dev/${ROOT_PART} ${MNT}/srv
mkdir -p ${MNT}/tmp       && mount -o subvol=@/tmp               /dev/${ROOT_PART} ${MNT}/tmp
mkdir -p ${MNT}/root      && mount -o subvol=@/root -o nodatacow /dev/${ROOT_PART} ${MNT}/root
mkdir -p ${MNT}/usr/local && mount -o subvol=@/usr/local         /dev/${ROOT_PART} ${MNT}/usr/local

mkdir -p ${MNT}/var       && mount -o subvol=@/var       /dev/${ROOT_PART} ${MNT}/var

BOOT_PART=sda3
mkdir -p ${MNT}/boot    && mount /dev/${BOOT_PART} ${MNT}/boot

HOME_PART=sda6
mkdir -p ${MNT}/home    && mount -o subvol=@home/        /dev/${HOME_PART} ${MNT}/home

mkdir --parents ${MNT}/etc
mkdir --parents ${MNT}/proc
genfstab -U ${MNT} >> ${MNT}/etc/fstab