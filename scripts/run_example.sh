#!/bin/sh

PROJECT_ROOT=$(realpath $(dirname $(dirname $0)))
SRC_DIR="$PROJECT_ROOT/src"

cd "$SRC_DIR"

echo "Insert the module"
insmod dmp.ko

echo "Create a temp file"
dd if=/dev/zero of=/tmp/disk1 bs=512 count=2000

echo "Attach loop device to this file"
losetup /dev/loop6 /tmp/disk1

echo "Create device with ‘basic_target’"
echo 0 2000 basic_target /dev/loop6 0|dmsetup create my_basic_target_device

echo "Writing the 1 sector on device"
dd if=/dev/zero of=/dev/mapper/my_basic_target_device bs=512 seek=10 count=1
