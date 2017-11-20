#!/usr/bin/env bash

# use blkid or lsblck to check what disk you destroy

HDD=sda

sudo su

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

sudo partprobe /dev/${HDD}

sudo mkfs.ext4 /dev/${HDD}2 -L boot
sudo mkswap /dev/${HDD}3 -L swap
sudo mkfs.btrfs /dev/${HDD}4 -L root
sudo mkfs.btrfs /dev/${HDD}5 -L home

#Idea taken from https://forums.opensuse.org/showthread.php/521277-LEAP-42-2-btrfs-root-filesystem-subvolume-structure

ROOT_PART=${HDD}4

# Create a new btrfs filesystem
# mkfs.btrfs /dev/${ROOT_PART}

# Mount subvolid=0 subvolume
TMP_MNT=/tmp/mnt
mkdir -p ${TMP_MNT}
sudo mount /dev/${ROOT_PART} -o subvolid=0 ${TMP_MNT}
############################

# Create the main snapshotted subvolume of the root filesystem
sudo btrfs subvolume create ${TMP_MNT}/@

# Create the non-snapshotted subvolumes

sudo btrfs subvolume create ${TMP_MNT}/@/opt
sudo btrfs subvolume create ${TMP_MNT}/@/srv
sudo btrfs subvolume create ${TMP_MNT}/@/tmp

sudo mkdir -p ${TMP_MNT}/@/boot/grub2 && \
sudo btrfs subvolume create ${TMP_MNT}/@/boot/grub2/i386-pc && \
sudo btrfs subvolume create ${TMP_MNT}/@/boot/grub2/x86_64-efi

sudo mkdir -p ${TMP_MNT}/@/usr && sudo btrfs subvolume create ${TMP_MNT}/@/usr/local

sudo mkdir -p ${TMP_MNT}/@/var && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/cache && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/crash && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/log && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/opt && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/spool && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/tmp && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/abs

sudo mkdir -p ${TMP_MNT}/@/var/lib/libvirt && sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/libvirt/images

sudo mkdir -p ${TMP_MNT}/@/var/lib && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/machines && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/mailman && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/mariadb && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/mysql && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/named && \
sudo btrfs subvolume create ${TMP_MNT}/@/var/lib/pgsql

# https://wiki.archlinux.org/index.php/Snapper:
# Keeping many of snapshots for a large timeframe on a busy filesystem like /, where many system updates happen over
# time, can cause serious slowdowns. You can prevent it by:
# Creating subvolumes for things that are not worth being snapshotted, like /var/cache/pacman/pkg, /var/abs, /var/tmp, and /srv


# WAT???
# mkdir -p ${TMP_MNT}/@ && btrfs subvolume create ${TMP_MNT}/@/pkg

#sudo btrfs subvolume delete /tmp/mnt/var/lib/machines/


#sudo btrfs subvolume create ${TMP_MNT}/@/.snapshots
# Create a place to keep snapshots and create an initial snapshot
#sudo mkdir ${TMP_MNT}/@/.snapshots/1
#sudo btrfs subvolume snapshot ${TMP_MNT}/@ ${TMP_MNT}/@/.snapshots/1/snapshot

# Find the ID of the initial snapshot and set it to be the default to be mounted
#sudo defaultsv="$(sudo btrfs subvolume list -o ${TMP_MNT}/@/.snapshots/1 | gawk '$NF ~ "1/snapshot$" {print $2}')"
#sudo btrfs subvolume set-default $defaultsv ${TMP_MNT}/@/.snapshots/1/snapshot

#mount -o subvol=@/var/lib/libvirt/images /dev/sdb2 /mnt/newfs/var/lib/libvirt/images
#mount -o subvol=@/var/lib/mariadb /dev/sdb2 /mnt/newfs/var/lib/mariadb
#mount -o subvol=@/var/lib/pgsql /dev/sdb2 /mnt/newfs/var/lib/pgsql
#mount -o subvol=@/var/lib/mysql /dev/sdb2 /mnt/newfs/var/lib/mysql
#mount -o subvol=@/var/log /dev/sdb2 /mnt/newfs/var/log && mkdir /var/log/journal
#chattr +C /mnt/newfs/var/lib/libvirt/images  /mnt/newfs/var/lib/mariadb /mnt/newfs/var/lib/pgsql /mnt/newfs/var/lib/mysql /var/log/journal

sudo mkdir ${TMP_MNT}/@/var/log/journal

sudo chattr +C \
    ${TMP_MNT}/@/var/lib/libvirt/images \
    ${TMP_MNT}/@/var/lib/mariadb \
    ${TMP_MNT}/@/var/lib/pgsql \
    ${TMP_MNT}/@/var/lib/mysql \
    ${TMP_MNT}/@/var/log/journal


# Finished - unmount complete filesystem
sudo umount ${TMP_MNT}

#TODO Исправить calamares

