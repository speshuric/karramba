#!/usr/bin/env bash

# use blkid or lsblck to check what disk you destroy

HDD=sda

sudo partprobe /dev/${HDD}

sudo parted --script /dev/${HDD} print

sudo parted --script /dev/${HDD} -- \
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

sudo partprobe /dev/${HDD}

sudo mkfs.ext4 /dev/sda2 -L boot
sudo mkfs.btrfs /dev/sda4 -L root
sudo mkfs.btrfs /dev/sda5 -L home
sudo mkswap /dev/sda3 -L swap

