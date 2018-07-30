#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

#install base

#choose kernels
CHOSEN_KERNELS=linux414 linux 418 
CHOSEN_AUR=yaourt base-devel 
CHOSEN_KERNEL_MODULES=linux414-headers linux414-virtualbox-guest-modules linux418-headers linux418-virtualbox-guest-modules 
