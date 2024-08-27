# meta-aos-rpi

This repository contains AodEdge Yocto layers for building Aos virtual machine.

## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE

2. Development packages for Yocto. Refer to [Yocto manual]
   (<https://docs.yoctoproject.org/brief-yoctoprojectqs/index.html#build-host-packages>).

3. You need `Moulin` of version 0.20 or newer installed in your PC. Recommended way is to install it for your user only:
   `pip3 install --user git+https://github.com/xen-troops/moulin`. Make sure that your `PATH` environment variable
    includes `${HOME}/.local/bin`.

4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetch

You can fetch/clone this whole repository, but you actually only need one file from it: `aos-rpi.yaml`.
During the build `moulin` will fetch this repository again into `yocto/` directory. So, to reduce possible confuse,
we recommend to download only `aos-rpi.yaml`:

```sh
curl -O https://raw.githubusercontent.com/aosedge/meta-aos-rpi/main/aos-rpi.yaml
```

## Build

Moulin is used to generate Ninja build file: `mouling aos-rpi.yaml`. This project provides number of additional
parameters. You can check them with`--help-config` command line option:

```sh
moulin aos-rpi.yaml --help-config
usage: moulin aos-rpi.yaml [--VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}] [--NODE_TYPE {main,secondary}] [--MACHINE {rpi5}] [--DOMD_ROOT {usb,nvme}]

Config file description: Raspberry 5 with xen dom0less

options:
  --VIS_DATA_PROVIDER {renesassimulator,telemetryemulator}
                        Specifies plugin for VIS automotive data
  --NODE_TYPE {main,secondary}
                        Node type to build
  --MACHINE {rpi5}      Raspberry Pi machines
  --DOMD_ROOT {usb,nvme}
                        Domd root device
```

* `NODE_TYPE` specifies the node to build: `main` - main node, `secondary` -
secondary node. By default, main node is built.

* `VIS_DATA_PROVIDER` - specifies VIS data provider: `renesassimulator` - Renesas Car simulator, `telemetryemulator` -
telemetry emulator that reads data from the local file. By default, Renesas Car simulator is used.

After performing moulin command with desired configuration, it will generate `build.ninja` with all necessary build
targets.

### Build dom0

Build dom0 image:

```sh
moulin aos-rpi.yaml
ninja && ninja dom0.img
```

Build domd image:

```sh
moulin aos-rpi.yaml
ninja && ninja domd.img
```

You should have `dom0.img` and `domd.img` files in the build folder.

### Flash dom0 image

To flash dom0 image on SD-card run below command:

```sh
sudo dd if=./dom0.img of=/dev/<sd-dev> bs=4M status=progress conv=sparse
```

**NOTE:** Be sure to identify correctly <sd-dev> which is usually "sda". For SD-card identification
Plug/unplug SD-card and check `/dev/` for devices added/removed.

**NOTE:** Ensure existing SD-card partitions unmounted if auto-mount is enabled.


### SD-card image content

The SD-card image **full.img** is created using GPT format and contains two FATFS partitions:

* First: 512Mb bootfs partition. Contains files required for RPI5 to boot.
* Second: 512MB dom0 partition. Exclusively used by Zephyr Dom0 `zephyr-dom0-xt` application
  and contains guest domains images.

### Flash domd rootfs image to the USB-flash

To flash USB-flash image run below command:
```sh
sudo dd if=./domd.img of=/dev/<usb-dev> bs=4M status=progress conv=sparse
```

**NOTE:** Be sure to identify correctly <usb-dev> which could look like "sdc".
For USB-flash identification Plug/unplug USB-flash and check `/dev/` for devices added/removed.

**NOTE:** Ensure existing USB-flash partitions unmounted if auto-mount is enabled.

### Flash domd rootfs image to the nvme storage

* Create Sd-card with official Ubuntu from Raspberry foundation.
* Copy file domd.img to the USB-Flash dongle.
* Boot from Sd card with Ubuntu. Plug USB-Flash dongle to the Raspberry Pi.
* Create partition on nvme storage with command (should be issued from root account):

```sh
(
echo o
echo n
echo p
echo 1
echo
echo +32G
echo w
) | fdisk /dev/nvme0n1
```

* Flash **"ext4"** image:

```sh
dd if=<usb-dev>/domd.img of=/dev/nvme0n1p1 bs=1M conv=sparse
```
