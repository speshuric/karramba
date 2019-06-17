# karramba

## What is here?
Some home install scripts. Probably you don't need it, but you can use it.

## Download

ARCH: Download as zip, unpack, start `1.init-install.sh`
```
wget https://github.com/speshuric/karramba/tarball/master -O - | tar xz 
mv speshuric-karramba-* karramba 
cd ./karramba/scripts
```

Shorter: 
```
wget https://git.io/fjRjE -O - | tar xz 

mv speshuric-karramba-* karramba 
cd ./karramba/scripts
./1.init-install.sh
```

Following work can be done via ssh:

```
ssh root@192.168.0.xxx -o StrictHostKeyChecking=no
```
It's no sence to check HostKey at the moment. It's temporary key and will be changed after install.


Download this repo and `aui`

```bash
wget https://gitlab.com/speshuric/karramba/repository/master/archive.tar.gz -O - | tar xz && mv karramba-* karramba
wget https://github.com/helmuthdu/aui/tarball/master -O - | tar xz && mv helmuthdu-aui-* aui 
```


clone
```bash
sudo pacman -Sy git && git clone https://gitlab.com/speshuric/karramba.git && cd karramba/scripts
```


## Source code

To edit: `git clone https://gitlab.com/speshuric/karramba.git`

## Docs

[Long story](./docs/log.md) 


