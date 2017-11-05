#!/usr/bin/env bash

#Taken from https://forums.opensuse.org/showthread.php/521277-LEAP-42-2-btrfs-root-filesystem-subvolume-structure

# blkid

hdd=sda3

# Create a new btrfs filesystem
mkfs.btrfs /dev/${hdd}

# Mount subvolid=0 subvolume
mkdir -p /mnt
mount /dev/${hdd} -o subvolid=0 /mnt

# Create the main snapshotted subvolume of the root filesystem
btrfs subvolume create /mnt/@

# Create the non-snapshotted subvolumes
mkdir -p /mnt/@ && btrfs subvolume create /mnt/@/.snapshots
mkdir -p /mnt/@/boot/grub2 && btrfs subvolume create /mnt/@/boot/grub2/i386-pc
mkdir -p /mnt/@/boot/grub2 && btrfs subvolume create /mnt/@/boot/grub2/x86_64-efi
mkdir -p /mnt/@ && btrfs subvolume create /mnt/@/opt
mkdir -p /mnt/@ && btrfs subvolume create /mnt/@/srv
mkdir -p /mnt/@ && btrfs subvolume create /mnt/@/tmp
mkdir -p /mnt/@/usr && btrfs subvolume create /mnt/@/usr/local
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/cache
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/crash
mkdir -p /mnt/@/var/lib/libvirt && btrfs subvolume create /mnt/@/var/lib/libvirt/images
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/machines
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/mailman
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/mariadb
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/mysql
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/named
mkdir -p /mnt/@/var/lib && btrfs subvolume create /mnt/@/var/lib/pgsql
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/log
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/opt
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/spool
mkdir -p /mnt/@/var && btrfs subvolume create /mnt/@/var/tmp

mkdir -p /mnt/@ && btrfs subvolume create /mnt/@/pkg


# Create a place to keep snapshots and create an initial snapshot
mkdir /mnt/@/.snapshots/1
btrfs subvolume snapshot /mnt/@ /mnt/@/.snapshots/1/snapshot

# Find the ID of the initial snapshot and set it to be the default to be mounted
defaultsv="$(btrfs subvolume list -o /mnt/@/.snapshots/1 | gawk '$NF ~ "1/snapshot$" {print $2}')"
btrfs subvolume set-default $defaultsv /mnt/@/.snapshots/1/snapshot

# Finished - unmount complete filesystem
umount /mnt