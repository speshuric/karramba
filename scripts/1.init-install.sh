#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

echo "Select Keymap"
# ls -R /usr/share/kbd/keymaps | grep "map.gz" | sed 's/\.map\.gz//g' | sort
loadkeys us

echo "Add space for tools"
mount -o remount,size=2G /run/archiso/cowspace

echo "Install reflector"
pacman -Sy reflector

echo "Configure Mirrorlist"
reflector --verbose --connection-timeout 1 -a 1 -l 50 -p https --sort rate --save /etc/pacman.d/mirrorlist

echo "Install git"
pacman -Sy git

if !(systemctl is-active --quiet sshd.service)
    echo "Set root password"
    passwd
fi

echo "Start ssh"
systemctl start sshd.service

echo "ip adrr"
ip -4 address | grep global


# для установщика manjaro
# sudo pacman-mirrors --api --protocol https --timeout 1
# touch /tmp/.btrfsroot
