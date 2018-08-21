#!/usr/bin/env bash

if [ "$(whoami)" != "root" ]; then
	echo "Root privileges required"
	exit 1
fi

# ls -R /usr/share/kbd/keymaps | grep "map.gz" | sed 's/\.map\.gz//g' | sort
loadkeys us
sudo pacman-mirrors --fasttrack --api --protocol https --timeout 1

# для установщика manjaro
touch /tmp/.btrfsroot
