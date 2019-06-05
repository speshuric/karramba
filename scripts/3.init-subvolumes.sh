#!/usr/bin/env bash

# constant part
RED='\033[0;31m'
NC='\033[0m' # No Color
GRN='\033[1;32m'

function log {
    echo -e "${GRN}$1${NC}"
}
function err {
    echo -e "${RED}$1${NC}"
    exit 1
}

if [ "$(whoami)" != "root" ]; then
    err "Root privileges required"
fi

#Subvolume list taken from 
# - https://forums.opensuse.org/showthread.php/521277-LEAP-42-2-btrfs-root-filesystem-subvolume-structure
# - installed OpenSuse fstab
# - https://en.opensuse.org/SDB:BTRFS#Default_Subvolumes

HDD=sda
# - Затычка для MBR
BIOS_GRUB_PART=${HDD}1
# - EFI Service Partition
ESP_PART=${HDD}2
# - /boot Partition
BOOT_PART=${HDD}3
# - swp Partition
SWAP_PART=${HDD}4
# - root Partition
ROOT_PART=${HDD}5
# - /home Partition
HOME_PART=${HDD}6
TMP_MNT=/tmp/mnt

# Create a new btrfs filesystem
# mkfs.btrfs /dev/${ROOT_PART}

# Mount subvolid=0 subvolume to temp mount

log "root - mount subvolid=0"
mkdir -p ${TMP_MNT}
mount /dev/${ROOT_PART} -o subvolid=0 ${TMP_MNT}
############################

# Create the main snapshotted subvolume of the root filesystem
btrfs subvolume create ${TMP_MNT}/@

# Create the non-snapshotted subvolumes
log "root - create subvols"
btrfs subvolume create ${TMP_MNT}/@/opt
btrfs subvolume create ${TMP_MNT}/@/srv
btrfs subvolume create ${TMP_MNT}/@/tmp
btrfs subvolume create ${TMP_MNT}/@/root
mkdir -p ${TMP_MNT}/@/usr && btrfs subvolume create ${TMP_MNT}/@/usr/local
btrfs subvolume create ${TMP_MNT}/@/var
btrfs subvolume create ${TMP_MNT}/@/.snapshots
# Create a place to keep snapshots and create an initial snapshot
#mkdir ${TMP_MNT}/@/.snapshots/1
btrfs subvolume set-default ${TMP_MNT}/@

# /boot in separate partition - do not create subvolumes
# mkdir -p ${TMP_MNT}/@/boot/grub2 && \
# btrfs subvolume create ${TMP_MNT}/@/boot/grub2/i386-pc && \
# btrfs subvolume create ${TMP_MNT}/@/boot/grub2/x86_64-efi

# https://wiki.archlinux.org/index.php/Snapper:
# Keeping many of snapshots for a large timeframe on a busy filesystem like /, where many system updates happen over
# time, can cause serious slowdowns. You can prevent it by:
# Creating subvolumes for things that are not worth being snapshotted, like /var/cache/pacman/pkg, /var/abs, /var/tmp, and /srv

# WAT???
# mkdir -p ${TMP_MNT}/@ && btrfs subvolume create ${TMP_MNT}/@/pkg

#btrfs subvolume delete /tmp/mnt/var/lib/machines/

#btrfs subvolume create ${TMP_MNT}/@/.snapshots


#btrfs subvolume snapshot ${TMP_MNT}/@ ${TMP_MNT}/@/.snapshots/1/snapshot
#btrfs subvolume set-default ${TMP_MNT}/@/.snapshots/1/snapshot ${TMP_MNT}/@/.snapshots/1/snapshot
#btrfs subvolume set-default ${TMP_MNT}/@/.snapshots/1/snapshot

# Find the ID of the initial snapshot and set it to be the default to be mounted
#defaultsv="$(btrfs subvolume list -o ${TMP_MNT}/@/.snapshots/1 | gawk '$NF ~ "1/snapshot$" {print $2}')"
#btrfs subvolume set-default $defaultsv ${TMP_MNT}/@/.snapshots/1/snapshot

#mount -o subvol=@/var/lib/libvirt/images /dev/sdb2 /mnt/newfs/var/lib/libvirt/images
#mount -o subvol=@/var/lib/mariadb /dev/sdb2 /mnt/newfs/var/lib/mariadb
#mount -o subvol=@/var/lib/pgsql /dev/sdb2 /mnt/newfs/var/lib/pgsql
#mount -o subvol=@/var/lib/mysql /dev/sdb2 /mnt/newfs/var/lib/mysql
#mount -o subvol=@/var/log /dev/sdb2 /mnt/newfs/var/log && mkdir /var/log/journal
#chattr +C /mnt/newfs/var/lib/libvirt/images  /mnt/newfs/var/lib/mariadb /mnt/newfs/var/lib/pgsql /mnt/newfs/var/lib/mysql /var/log/journal

#mkdir ${TMP_MNT}/@/var/log/journal

#chattr +C \
#    ${TMP_MNT}/@/var/lib/libvirt/images \
#    ${TMP_MNT}/@/var/lib/mariadb \
#    ${TMP_MNT}/@/var/lib/pgsql \
#    ${TMP_MNT}/@/var/lib/mysql \
#    ${TMP_MNT}/@/var/log/journal

#btrfs subvolume set-default ${TMP_MNT}/@

# Finished - unmount complete filesystem
log "root - umount subvolid=0"
umount ${TMP_MNT}

log "home - mount subvolid=0"
mkdir -p ${TMP_MNT}
mount /dev/${HOME_PART} -o subvolid=0 ${TMP_MNT}
############################

log "home - create subvols"
btrfs subvolume create ${TMP_MNT}/@home

log "home - umount subvolid=0"
# Finished - unmount complete filesystem
umount ${TMP_MNT}