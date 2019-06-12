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

HDD=sda
log "Default drive ${NC} ${HDD}"

log "partprobe"
# make shure that sda partitions are actual
partprobe /dev/${HDD}

log "print current layout"
parted --script /dev/${HDD} print

# My partitioning:
# sda  - create gpt table
# sda1 - bios_grub - 3 MiB    - small partition for MBR boot on GPT https://askubuntu.com/questions/500359/efi-boot-partition-and-biosgrub-partition/501360
# sda2 - esp       - ~0.5 GiB - EFI System Partition (ESP) - https://askubuntu.com/questions/500359/efi-boot-partition-and-biosgrub-partition/501360
# sda3 - boot      - ~4.5 GiB - ext4 /boot partition - needed because of combination of BTRFS & GRUB & ... 
# sda4 - swap      - 29 GiB   - I have 24GiB RAM, so swap should be more than it
# sda5 - root      - ~160 GiB - btrfs root "/" partition (for snapper), should be enough
# sda6 - home      - rest of drive - btrfs "/home" partition. last 8% of SSD are reserved

# $ parted --script /dev/${HDD} print
# Output:
# Number  Start   End     Size    File system     Name       Flags
#  1      1049kB  4194kB  3146kB                  bios_grub  bios_grub
#  2      4194kB  537MB   533MB                   esp        boot, esp
#  3      537MB   5369MB  4832MB  ext4            boot
#  4      5369MB  34.4GB  29.0GB  linux-swap(v1)  swap
#  5      34.4GB  193GB   159GB   btrfs           root
#  6      193GB   1472GB  1279GB  btrfs

log "repartition"
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
    mkpart primary btrfs      32GiB  96GiB \
        name 5 root \
    mkpart primary btrfs      96GiB  92% \
        name 6 home \
    print \

log "partprobe again"
partprobe /dev/${HDD}

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

log "Create filesystems:"
log "  ESP"
# mkfs.fat /dev/${ESP_PART} -F32 -S 4096 
mkfs.fat /dev/${ESP_PART} -F32  -n esp
log "  mkfs boot"
mkfs.ext4 /dev/${BOOT_PART}  -F -L boot
log "  mkswap"
mkswap /dev/${SWAP_PART}        -L swap
log "  root"
mkfs.btrfs /dev/${ROOT_PART} -f -L root
log "  home"
mkfs.btrfs /dev/${HOME_PART} -f -L home
