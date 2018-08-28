#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

ROOT_PART=sda5
MNT=/mnt

mkdir -p ${MNT}           && mount -o subvol=@/          /dev/${ROOT_PART} ${MNT}
mkdir -p ${MNT}/opt       && mount -o subvol=@/opt       /dev/${ROOT_PART} ${MNT}/opt
mkdir -p ${MNT}/srv       && mount -o subvol=@/srv       /dev/${ROOT_PART} ${MNT}/srv
mkdir -p ${MNT}/tmp       && mount -o subvol=@/tmp       /dev/${ROOT_PART} ${MNT}/tmp
mkdir -p ${MNT}/usr/local && mount -o subvol=@/usr/local /dev/${ROOT_PART} ${MNT}/usr/local

mkdir -p ${MNT}/var/cache && mount -o subvol=@/var/cache /dev/${ROOT_PART} ${MNT}/var/cache
mkdir -p ${MNT}/var/crash && mount -o subvol=@/var/crash /dev/${ROOT_PART} ${MNT}/var/crash
mkdir -p ${MNT}/var/log   && mount -o subvol=@/var/log   /dev/${ROOT_PART} ${MNT}/var/log
mkdir -p ${MNT}/var/opt   && mount -o subvol=@/var/opt   /dev/${ROOT_PART} ${MNT}/var/opt
mkdir -p ${MNT}/var/spool && mount -o subvol=@/var/spool /dev/${ROOT_PART} ${MNT}/var/spool
mkdir -p ${MNT}/var/tmp   && mount -o subvol=@/var/tmp   /dev/${ROOT_PART} ${MNT}/var/tmp
mkdir -p ${MNT}/var/abs   && mount -o subvol=@/var/abs   /dev/${ROOT_PART} ${MNT}/var/abs

mkdir -p ${MNT}/var/lib/libvirt/images && mount -o subvol=@/var/lib/libvirt/images /dev/${ROOT_PART} ${MNT}/var/lib/libvirt/images
mkdir -p ${MNT}/var/lib/machines && mount -o subvol=@/var/lib/machines /dev/${ROOT_PART} ${MNT}/var/lib/machines
mkdir -p ${MNT}/var/lib/mailman  && mount -o subvol=@/var/lib/mailman  /dev/${ROOT_PART} ${MNT}/var/lib/mailman
mkdir -p ${MNT}/var/lib/mariadb  && mount -o subvol=@/var/lib/mariadb  /dev/${ROOT_PART} ${MNT}/var/lib/mariadb
mkdir -p ${MNT}/var/lib/mysql    && mount -o subvol=@/var/lib/mysql    /dev/${ROOT_PART} ${MNT}/var/lib/mysql
mkdir -p ${MNT}/var/lib/named    && mount -o subvol=@/var/lib/named    /dev/${ROOT_PART} ${MNT}/var/lib/named
mkdir -p ${MNT}/var/lib/pgsql    && mount -o subvol=@/var/lib/pgsql    /dev/${ROOT_PART} ${MNT}/var/lib/pgsql

BOOT_PART=sda3
mkdir -p ${MNT}/boot    && mount /dev/${BOOT_PART} ${MNT}/boot

HOME_PART=sda6
mkdir -p ${MNT}/home    && mount -o subvol=@home/        /dev/${HOME_PART} ${MNT}/home