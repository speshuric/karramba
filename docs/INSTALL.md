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
- [x] enable SSH by default
- [x] create `ansible_install` user to do installation
- [ ] create private/public key for ansible user (for key-based SSH)
- [ ] create private/public key for host (for known_hosts)
- [x] generated safe password
- [ ] disable `root` ssh access since we do not need it
- [x] disable `root` autologon
- [ ] set `hostname`
- [x] install git, ansible 
- [x] get mirrorlist from current installation

Optional:
- set `keymaps`
- set `setfont`
- install drivers
- set up network (spescial case - broadcom)


### In standard live ISO

This is recommended way to create 'clean' media. 

1. Create VM. Minimal requirements: 
    - CPU: 2 (create ISO media contains tasks scaled by CPU)
    - RAM: 2GB, *4GB recommended*
    - HDD: Not used at all
    - LAN: Check that you can connect SSH(22) to this VM
2. [Download](https://www.archlinux.org/download/) arch installation media
3. [Verify](https://wiki.archlinux.org/index.php/Installation_guide#Verify_signature) arch installation media
4. Boot in VM with standard Arch Installation ISO
5. Change `root` password, start SSH
```sh
passwd
systemctl start sshd.socket
```
6. Check network (`ping 8.8.8.8` or something similar)
7. Login through SSH to `root@VM` (`VM` means address of this VM): 
```sh
ssh root@VM -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
```
> **Note:** See below about options!
8. Execute:
```sh
pacman -Syy
pacman -Sy git
git clone https://gitlab.com/speshuric/karramba.git
cd ./karramba/scripts
./1.init-install.sh
```
9. Start ISO creation:
```sh
./
``` 
10. Last line should be smth like  `Arch installation ISO created in /tmp/archiso_NNNNN/out/`
11. You can disconnect from VM
12. To copy output folder to control machine execute from control machine:
```sh
mkdir ~/iso
scp -r -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@VM:/tmp/archiso_NNNNN/out/* ~/iso/
```
> **Note:** See below about options!
13. Check output. Directory `~/iso/` should contain:
    - `archlinux-2019.06.20-x86_64.iso` - installation image
    - `passwords` - randomly generated passwords for `root` and `ansible_install`. Usually you don't have to use it, except case when network is not operating properly
    - `ansible_install_key` - private key for `ansible_install` user
    - `ansible_install_key.pub` - public key for `ansible_install` user
    - `ssh_host_dsa_key`, `ssh_host_dsa_key.pub`, `ssh_host_ecdsa_key`, `ssh_host_ecdsa_key.pub`, `ssh_host_ed25519_key`, `ssh_host_ed25519_key.pub`, `ssh_host_rsa_key`, `ssh_host_rsa_key.pub` - keys for `known_hosts`
    
Notes:
- `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null` used to avoid accumulation of one-time host keys. 

### In current arch installation
> TODO:

### In Ubuntu
> TODO:

### In Windows
> TODO:

## Boot with installation media and set up pre install.

## Tune ansible playboooks

## Execute ansible playboooks