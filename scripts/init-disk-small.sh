#!/usr/bin/env bash

# use blkid or lsblck to check what disk you destroy

HDD=sda

partprobe /dev/${HDD}
parted --script /dev/${HDD} print

parted --script /dev/${HDD} -- \
    unit MiB \
    mklabel gpt \
    mkpart primary 1MiB 4MiB \
    set 1 bios_grub on \
    name 1 bios_grub \
    mkpart primary linux-swap 4MiB 6GiB \
    name 2 swap \
    mkpart primary btrfs 6GiB 50GiB \
    name 3 root \
    mkpart primary btrfs 50GiB 92% \
    name 4 home \
    print \

partprobe /dev/${HDD}

mkswap /dev/${HDD}2 -fL swap
mkfs.btrfs /dev/${HDD}3 -fL root
mkfs.btrfs /dev/${HDD}4 -fL home

#Idea taken from https://forums.opensuse.org/showthread.php/521277-LEAP-42-2-btrfs-root-filesystem-subvolume-structure
