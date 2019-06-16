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

log "Select Keymap"
# ls -R /usr/share/kbd/keymaps | grep "map.gz" | sed 's/\.map\.gz//g' | sort
loadkeys us
loadkeys ru
setfont cyr-sun16

log "Add space for tools"
mount -o remount,size=2G /run/archiso/cowspace

log "Install reflector"
pacman -Sy --noconfirm reflector

log "Configure Mirrorlist"
reflector \
    --verbose\
    --connection-timeout 1\
    --cache-timeout 10\
    --age 10\
    --latest 100\
    --number 20\
    --protocol https\
    --sort rate\
    --threads 10\
    --save /etc/pacman.d/mirrorlist

log "Install git"
pacman -Sy --noconfirm git

# if ssd is not started, set password and start it
if !(systemctl -q is-active sshd.service)
    then

    log "Set root password"
    passwd

    log "Start ssh"
    systemctl start sshd.service

    log "ip adrr"
    ip -4 address | grep global
fi


