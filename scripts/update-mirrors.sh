#!/usr/bin/env bash

# from https://antergos.com/wiki/uncategorized/how-to-choose-your-mirrors-before-installing-antergos/
# setup mirrors
sudo pacman -S pacman-mirrorlist antergos-mirrorlist
sudo mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist

# this doesn't work, there is no antergos-mirrorlist.pacnew
sudo mv /etc/pacman.d/antergos-mirrorlist.pacnew /etc/pacman.d/antergos-mirrorlist
pacman -Syy

# show ranking
rankmirrors -v /etc/pacman.d/mirrorlist

# this doesn't work, rankmirrors doesn't work correctly with antergos-mirrorlist.pacnew
rankmirrors -v /etc/pacman.d/antergos-mirrorlist
# todo: check ranking in cnchi
