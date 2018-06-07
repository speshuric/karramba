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
    mkpart primary ext4 4MiB 4GiB \
    set 2 boot on \
    set 2 esp on \
    name 2 boot \
    mkpart primary linux-swap 4GiB 32GiB \
    name 3 swap \
    mkpart primary btrfs 32GiB 80GiB \
    name 4 root \
    mkpart primary btrfs 80GiB 92% \
    name 5 home \
    print \

partprobe /dev/${HDD}

mkfs.ext4 /dev/${HDD}2 -L boot
mkswap /dev/${HDD}3 -L swap
mkfs.btrfs /dev/${HDD}4 -L root
mkfs.btrfs /dev/${HDD}5 -L home


