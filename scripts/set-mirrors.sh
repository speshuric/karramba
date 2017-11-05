#!/usr/bin/env bash
cd $(dirname $0)
pwd
sudo cp ../files/etc/pacman.d/mirrorlist.hardcoded /etc/pacman.d/mirrorlist
sudo cp ../files/etc/pacman.d/antergos-mirrorlist.hardcoded /etc/pacman.d/antergos-mirrorlist