#!/usr/bin/env bash

# use blkid or lsblk to check what disk you destroy

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

HDD=sda

# make shure that sda partitions are actual
partprobe /dev/${HDD}

parted --script /dev/${HDD} print

# My partitioning:
# sda  - create gpt table
# sda1 - bios_grub - 3 MiB    - small partition for MBR boot on GPT https://askubuntu.com/questions/500359/efi-boot-partition-and-biosgrub-partition/501360
# sda2 - esp       - ~0.5 GiB - EFI System Partition (ESP) - https://askubuntu.com/questions/500359/efi-boot-partition-and-biosgrub-partition/501360
# sda3 - boot      - ~4.5 GiB - ext4 /boot partition - needed because of combination of BTRFS & GRUB & ... 
# sda4 - swap      - 29 GiB   - I have 24GiB RAM, so swap should be more than it
# sda5 - root      - ~160 GiB - btrfs root "/" partition (for snapper), should be enough
# sda6 - home      - rest of drive - btrfs "/home" partition. last 8% of SSD are reserved

# Number  Start   End     Size    File system     Name       Flags
#  1      1049kB  4194kB  3146kB                  bios_grub  bios_grub
#  2      4194kB  537MB   533MB                   esp        boot, esp
#  3      537MB   5369MB  4832MB  ext4            boot
#  4      5369MB  34.4GB  29.0GB  linux-swap(v1)  swap
#  5      34.4GB  193GB   159GB   btrfs           root
#  6      193GB   1472GB  1279GB  btrfs


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

partprobe /dev/${HDD}

mkfs.ext4 /dev/${HDD}3  -F -L boot
mkswap /dev/${HDD}4     -L swap
mkfs.btrfs /dev/${HDD}5 -f -L root
mkfs.btrfs /dev/${HDD}6 -f -L home
