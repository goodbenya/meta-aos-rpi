#!/bin/sh

SEPARATOR="================================================================="

wait_sync() {
    sleep 3
    sync
}

BLOCK_DEVICE=$1
if [ "$BLOCK_DEVICE" = "sda" ]; then
    BLOCK_DEVICE_PARTITION="sda1"
else
    BLOCK_DEVICE_PARTITION="nvme0n1p1"
fi

echo "$SEPARATOR"
echo "Welcome to AOS RPI! Setting up your system for a smooth experience."
echo "$SEPARATOR"

echo "Initializing the file system..."
PATH=/sbin:/bin:/usr/sbin:/usr/bin

mkdir -p /proc /sys /dev
mount -t proc proc /proc || echo "Failed to mount /proc"
mount -t sysfs sysfs /sys || echo "Failed to mount /sys"
mount -t devtmpfs dev /dev || echo "Failed to mount /dev"
wait_sync

echo "Preparing the flash drive..."
echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/"$BLOCK_DEVICE" || echo "Failed to partition /dev/$BLOCK_DEVICE"
mkfs.ext4 -L "TEMP" -F -E lazy_journal_init=1 /dev/$BLOCK_DEVICE_PARTITION || echo "Failed to format /dev/$BLOCK_DEVICE_PARTITION"
mkdir -p /flash
mount -t auto /dev/$BLOCK_DEVICE_PARTITION /flash || echo "Failed to mount /dev/sda1"
wait_sync

echo "Preparing the SD card..."
mkdir -p /sd
mount -t auto /dev/mmcblk0p2 /sd || echo "Failed to mount /dev/mmcblk0p2"
wait_sync

echo "Flashing the flash drive... This process typically takes around 10 minutes. "
umount /flash
wait_sync

dd if=/dev/zero of=/dev/"$BLOCK_DEVICE" bs=1M count=10 || echo "Failed to zero out /dev/$BLOCK_DEVICE"
dd if=/sd/rootfs.img of=/dev/"$BLOCK_DEVICE" bs=4M || echo "Failed to write rootfs.img"
wait_sync

mount -t auto /dev/$BLOCK_DEVICE_PARTITION /flash || echo "Failed to remount /dev/$BLOCK_DEVICE_PARTITION"
wait_sync

echo "Flashing the SD card... This process typically takes around 3 minutes. "
mkdir -p /flash/tmp
cp -v /sd/boot.img /flash/tmp || echo "Failed to copy boot.img to tmp"

umount /sd
wait_sync
dd if=/dev/zero of=/dev/mmcblk0 bs=1M count=10 || echo "Failed to zero out /dev/mmcblk0"
dd if=/flash/tmp/boot.img of=/dev/mmcblk0 bs=4M || echo "Failed to write boot.img"
wait_sync

echo "$SEPARATOR"
echo "Installation complete! Please restart your device to apply the changes."
echo "$SEPARATOR"
