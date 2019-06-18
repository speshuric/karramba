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
[v] enable SSH by default
[v] create `ansible_install` user to do installation
[ ] create private/public key for ansible user (for key-based SSH)
[ ] create private/public key for host (for known_hosts)
[v] generated safe password
[ ] disable `root` ssh access since we do not need it
[ ] disable `root` autologon
[v] install git, ansible 
[v] get mirrorlist from current installation

Optional:
- set `keymaps`
- set `setfont`
- install drivers
- set up network (spescial case - broadcom)


### In standard live ISO

This is recommended way to create 'clean' media. 

1. Create VM. Minimal requirements: 
    - CPU: 2 (create ISO media contains paralellable CPU tasks)
    - RAM: 2GB, *4GB recommended*
    - HDD: Not used at all
    - LAN: Check that you can connect SSH(22) to this VM
2. Download arch installation media
3. Verify arch installation media
4. Boot in VM
5. Change `root` password
```sh
passwd
systemctl start sshd.socket
```
6. Check network
7. Login through SSH to `root@VM`
8. Execute:
```sh
pacman -Sy git
git clone https://gitlab.com/speshuric/karramba.git
cd ./karramba/scripts
./1.init-install.sh
```
9. Start ISO creation. Last line should be smth lite  `Arch installation ISO created in /tmp/archiso_9kFCk/out/`
11. You can disconnect from VM
10. To copy output folder to control machile:
```sh
scp -r root@VM:/tmp/archiso_9kFCk/out ~/iso
```

Notes:
- 

### In current arch installation



## Boot with installation media and set up pre install.

## Tune ansible playboooks

## Execute ansible playboooks