SUMMARY = "Aos image for Raspberry Pi devices"

require recipes-core/images/core-image-minimal.bb
require recipes-core/images/aos-image.inc

RDEPENDS += "rpi-bootfiles trusted-firmware-a"

do_image[depends] += " \
    rpi-bootfiles:do_deploy \
    trusted-firmware-a:do_deploy \
    ${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot-tools-native:do_populate_sysroot', '',d)} \
    ${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot:do_deploy', '',d)} \
    ${@bb.utils.contains('RPI_USE_U_BOOT', '1', 'u-boot-default-script:do_deploy', '',d)} \
"

IMAGE_INSTALL:append = " \
    coreutils \
    kernel-modules \
    u-boot \
    virtual-xenstored \
    xen \
    xen-network \
    xen-tools-devd \
    xen-tools-devd \
    xen-tools-scripts-block \
    xen-tools-scripts-network \
    xen-tools-vchan \
    xen-tools-xenstore \
"


IMAGE_INSTALL:append = " \
    bash \
    devmem2 \
    dnsmasq \
    e2fsprogs \
    openssh \
    optee-test \
    pciutils \
    tcpdump \
"

IMAGE_INSTALL:append = " \
    aos-messageproxy \
    aos-deprov \
"

# Set fixed rootfs size
IMAGE_ROOTFS_SIZE ?= "1048576"
IMAGE_OVERHEAD_FACTOR ?= "1.0"
IMAGE_ROOTFS_EXTRA_SPACE ?= "524288"
