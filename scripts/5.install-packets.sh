#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

HDD=sda

#install base

#choose kernels
#CHOSEN_KERNELS=linux414 linux418 
#CHOSEN_AUR=yaourt base-devel 
#CHOSEN_KERNEL_MODULES=linux414-headers linux414-virtualbox-guest-modules linux418-headers linux418-virtualbox-guest-modules 


manjaro-chroot /mnt "grub-install --target=i386-pc --recheck /dev/${HDD}"
