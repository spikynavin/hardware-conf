# Yocto-build conf

This repo contains build conf for raspberrypi for Yocto kirkstone.

```bash
MACHINE ?= "raspberrypi3-64"
```
Check the download and sstate-cache path for build files and tar balls.

```bash
DL_DIR ?= "${TOPDIR}/../build/downloads"
SSTATE_DIR ?= "${TOPDIR}/../build/cache/sstate-cache"
```
Below meta-layers are added in the build.
```bash
meta-raspberrypi
meta-openembedded/meta-oe
meta-openembedded/meta-filesystems
meta-openembedded/meta-gnome
meta-openembedded/meta-initramfs
meta-openembedded/meta-multimedia
meta-openembedded/meta-networking
meta-openembedded/meta-perl
meta-openembedded/meta-python
meta-virtualization
meta-elinux
```
