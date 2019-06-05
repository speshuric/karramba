#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

MNT=/tmp/mnt

umount ${MNT}/usr/local
umount ${MNT}/opt
umount ${MNT}/srv
umount ${MNT}/tmp
umount ${MNT}/root
umount ${MNT}/var
umount ${MNT}/boot
umount ${MNT}/home
umount ${MNT}/efi

umount ${MNT}




