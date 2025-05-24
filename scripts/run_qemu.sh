#!/bin/bash

PROJECT_ROOT=$(realpath $(dirname $(dirname $0)))
KERNEL_IMAGE="$PROJECT_ROOT/build/linux-6.14/arch/x86_64/boot/bzImage"
INITRAMFS="$PROJECT_ROOT/build/initramfs.tgz"
MODULE_DIR="$PROJECT_ROOT/src"

cd "$MODULE_DIR" && make clean QEMU_BUILD=1 && make QEMU_BUILD=1

qemu-system-x86_64 \
    -m 1G \
    -nographic \
    -kernel "$KERNEL_IMAGE" \
    -initrd "$INITRAMFS" \
    -append "console=ttyS0 nokaslr rdinit=/init" \
    -virtfs local,path="$PROJECT_ROOT",mount_tag=hostshare,security_model=mapped,id=hostshare \
    -serial mon:stdio \
    -no-reboot
