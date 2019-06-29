# ansible-arch

This document describes how to install Arch Linux with ansible playbooks. 
Goals:
- Repeatable unattended installs
- Scalable installs
- Dry and clean installed system
- Full control over installation process
- Simple (in Arch's sense of simplicity) and easy for user install
- Fast install

# Oerview of setup process

Stages of installation
- Create installation media
- Install before `chroot`
- Install before first boot
- Polish

## Mastering installation media.

Diiferences between standard installation media and remastered following:
- [x] enable SSH by default
- [x] create `ansible_install` user to do installation
- [x] `ansible_install` added to sudoers and can `sudo` without password
- [x] create private/public key for ansible user (for key-based SSH)
- [x] create private/public key for host (for known_hosts)
- [x] generated safe password
- [x] disable `root` ssh access since we do not need it
- [x] disable `root` autologon
- [x] set `hostname` to identify hosts booted with this ISO
- [x] install git, ansible 
- [ ] get mirrorlist from current installation
- [ ] add cowspace
- [ ] reduce syslinux bootloader menu waiting timeout

Optional:
- set `keymaps`
- set `setfont`
- install drivers
- set up network (spescial case - broadcom)


### In standard Arch linux live ISO

This is recommended way to create 'clean' media. 

1. Create VM. Minimal requirements: 
    - CPU: 2 (create ISO media contains tasks scaled by CPU)
    - RAM: 4GB, *more recommended*
        - By default `cowspace` in RAM used to build iso. If you can not allocate such amount of RAM you can mount persistance drive and change `archisodir` in `create_arch_iso.sh`
    - HDD: Not used at all
    - LAN: Check that you can connect SSH (22) to this VM from control machine
2. [Download](https://www.archlinux.org/download/) arch installation media
3. [Verify](https://wiki.archlinux.org/index.php/Installation_guide#Verify_signature) arch installation media
4. Boot in VM with standard Arch Installation ISO
5. Change `root` password, start SSH:
```shell
passwd
systemctl start sshd.socket
```
6. Check network (`ping 8.8.8.8` or something similar)
7. Login through SSH to `root@archiso` (`archiso` means this VM): 
```shell
ssh root@archiso -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```
> **Note:** See below about options!
8. Execute:
```shell
pacman -Syy git
git clone https://gitlab.com/speshuric/karramba.git
cd ./karramba/scripts
./1.init-install.sh
```
9. Start ISO creation:
```shell
./create_arch_iso.sh
``` 
10. Last line should be smth like  `Arch installation ISO created in /root/archiso_XXXXX/out/`
11. Check output. Output directory from previous step should contain:
    - `archlinux-YYYY.MM.DD-x86_64.iso` - installation image
    - `passwords` - randomly generated passwords for `root` and `ansible_install`. Usually you don't have to use it, except case when network is not operating properly
    - `ansible_install_key` - private key for `ansible_install` user
    - `ansible_install_key.pub` - public key for `ansible_install` user
    - `ssh_host_dsa_key`, `ssh_host_dsa_key.pub`, `ssh_host_ecdsa_key`, `ssh_host_ecdsa_key.pub`, `ssh_host_ed25519_key`, `ssh_host_ed25519_key.pub`, `ssh_host_rsa_key`, `ssh_host_rsa_key.pub` - keys for `known_hosts`
12. You can disconnect from VM
13. Copy output folder to control machine execute from control machine:
```shell
mkdir ~/iso
scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@archiso:/root/archiso_NNNNN/out/ ~/iso/
```
> **Note:** See below about options!
14. `ssh` ~/.ssh/authorized_keys
15. `known_hosts`: 
    
Notes:
- `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null` used to avoid accumulation of one-time host keys.
- **Do not** publish private keys and passwords. Keep it secure and private.
- Avoid publish ISO file. It contains your generated trusted private key of host and public key of `ansible_install` user.
- Password authentication in SSH for user `ansible_install` is **not** disabled.  

### In current arch installation
> TODO:

### In Ubuntu
> TODO:

### In Windows
> TODO:
### In Vagrant
This is recommended way to test build
> TODO:

### In Docker 
> TODO:

## Boot with installation media and set up pre install.

## Tune ansible playboooks

## Execute ansible playboooks