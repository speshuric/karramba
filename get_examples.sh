#!/usr/bin/env bash

function git_update {
    if [ -d "$1" ]; then
        pushd $1 > /dev/null
        echo "$1:"
        git pull --recurse-submodules
        popd > /dev/null
    else 
        echo "https://github.com/$1.git : "
        git clone --recurse-submodules "https://github.com/$1.git"  "$1"
    fi
}

mkdir -p ./examples
pushd ./examples > /dev/null
git_update id101010/ansible-archlinux
git_update pigmonkey/spark
git_update jahrik/ansible-arch-workstation
git_update v0rn/ansible-arch
git_update dharmab/ansible-archlinux
git_update mrkkrp/arch-workstation
git_update Titan-C/archlinux-ansible
git_update raphiz/my-arch-setup
git_update zoresvit/ansible-arch-linux
git_update nsg/ansible-arch-install
git_update lgaggini/ansible-arch

git_update helmuthdu/aui
git_update virtapi/LARS
git_update lukesmithxyz/larbs

popd > /dev/null