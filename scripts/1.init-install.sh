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

log "Set Keymap"
# ls -R /usr/share/kbd/keymaps | grep "map.gz" | sed 's/\.map\.gz//g' | sort
loadkeys ru
# ls /usr/share/kbd/consolefonts
setfont cyr-sun16

log "Add space for tools"
mount -o remount,size=1G /run/archiso/cowspace
log "Update time"
timedatectl set-ntp true

log "Install reflector"
pacman -Sy --noconfirm reflector
log "Install git"
pacman -Sy --noconfirm git

log "Configure Mirrorlist"
reflector \
    --verbose\
    --connection-timeout 1\
    --cache-timeout 10\
    --age 5\
    --latest 70\
    --number 20\
    --protocol https\
    --sort rate\
    --threads 10\
    --save /etc/pacman.d/mirrorlist

log "Update pacman database"
pacman -Syyu

log "ip adrr"
ip -4 address | grep global



