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

MNT=/tmp/mnt

log "mount root && subvols"
mkdir -p ${MNT}           && mount                               /dev/${ROOT_PART} ${MNT}
mkdir -p ${MNT}/opt       && mount -o subvol=@/opt               /dev/${ROOT_PART} ${MNT}/opt
mkdir -p ${MNT}/srv       && mount -o subvol=@/srv               /dev/${ROOT_PART} ${MNT}/srv
mkdir -p ${MNT}/tmp       && mount -o subvol=@/tmp               /dev/${ROOT_PART} ${MNT}/tmp
mkdir -p ${MNT}/root      && mount -o subvol=@/root -o nodatacow /dev/${ROOT_PART} ${MNT}/root
mkdir -p ${MNT}/usr/local && mount -o subvol=@/usr/local         /dev/${ROOT_PART} ${MNT}/usr/local
mkdir -p ${MNT}/var       && mount -o subvol=@/var               /dev/${ROOT_PART} ${MNT}/var

log "mount boot"
mkdir -p ${MNT}/boot      && mount                               /dev/${BOOT_PART} ${MNT}/boot

log "mount home"
mkdir -p ${MNT}/home      && mount -o subvol=@home/              /dev/${HOME_PART} ${MNT}/home

log "mount efi"
mkdir -p ${MNT}/efi       && mount                               /dev/${BIOS_GRUB_PART} ${MNT}/efi

log "make other dirs"
mkdir -p ${MNT}/etc
mkdir -p ${MNT}/proc
mkdir -p ${MNT}/sys
mkdir -p ${MNT}/dev
mkdir -p ${MNT}/run

log "genfstab"
genfstab -U ${MNT} >> ${MNT}/etc/fstab