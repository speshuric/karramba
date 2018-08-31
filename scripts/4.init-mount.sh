#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

ROOT_PART=sda5
MNT=/mnt

mkdir -p ${MNT}           && mount -o                            /dev/${ROOT_PART} ${MNT}
echo 1
mkdir -p ${MNT}/opt       && mount -o subvol=@/opt               /dev/${ROOT_PART} ${MNT}/opt
echo 2
mkdir -p ${MNT}/srv       && mount -o subvol=@/srv               /dev/${ROOT_PART} ${MNT}/srv
echo 3
mkdir -p ${MNT}/tmp       && mount -o subvol=@/tmp               /dev/${ROOT_PART} ${MNT}/tmp
mkdir -p ${MNT}/root      && mount -o subvol=@/root -o nodatacow /dev/${ROOT_PART} ${MNT}/root
mkdir -p ${MNT}/usr/local && mount -o subvol=@/usr/local         /dev/${ROOT_PART} ${MNT}/usr/local

mkdir -p ${MNT}/var       && mount -o subvol=@/var       /dev/${ROOT_PART} ${MNT}/var

BOOT_PART=sda3
mkdir -p ${MNT}/boot    && mount /dev/${BOOT_PART} ${MNT}/boot

HOME_PART=sda6
mkdir -p ${MNT}/home    && mount -o subvol=@home/        /dev/${HOME_PART} ${MNT}/home