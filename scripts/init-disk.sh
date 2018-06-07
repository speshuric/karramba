#!/usr/bin/env bash

# use blkid or lsblck to check what disk you destroy

HDD=sda

partprobe /dev/${HDD}
parted --script /dev/${HDD} print

parted --script /dev/${HDD} -- \
    unit MiB \
    mklabel gpt \
    mkpart primary            1MiB   4MiB \
        set 1 bios_grub on \
        name 1 bios_grub \
    mkpart primary fat32      4MiB   512MiB \
        set 2 esp on \
        set 2 boot on \
        name 2 esp \
    mkpart primary ext4       512MiB 5GiB \
        name 3 boot \
    mkpart primary linux-swap 5GiB   32GiB \
        name 4 swap \
    mkpart primary btrfs      32GiB  80GiB \
        name 5 root \
    mkpart primary btrfs      80GiB  92% \
        name 6 home \
    print \

partprobe /dev/${HDD}

# mkfs.ext4 /dev/${HDD}2 -L boot
# mkswap /dev/${HDD}3 -L swap
# mkfs.btrfs /dev/${HDD}4 -L root
# mkfs.btrfs /dev/${HDD}5 -L home


