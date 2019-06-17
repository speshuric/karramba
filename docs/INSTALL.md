# ansible-arch

This describes install Arch Linux with ansible playbooks. 
Goals:
- Repeatable unattended installs
- Scalable installs
- 

# Oerview of setup process

Stages of insatllation

## Mastering installation media.

Your own installation media alloows following:
- enable SSH by default
- create `ansible` user to do installation
- create private/public key for ansible user (for key-based SSH)
- disable `root` since we do not need it
- install git, ansible 
- get current mirrorlist

### In current arch installation

### In standard live ISO

1. Boot
2. 

## Boot with installation media and set up pre install.

## Tune ansible playboooks

## Execute ansible playboooks