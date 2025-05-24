#!/bin/bash
set -e

PROJECT_ROOT=$(realpath $(dirname $(dirname $0)))
BUILD_DIR="$PROJECT_ROOT/build"
LINUX_DIR="$BUILD_DIR/linux-6.14"
ROOTFS_DIR="$BUILD_DIR/initramfs"
ALPINE_VERSION="3.19.1"

echo "Setting up development environment"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Downloading Linux kernel..."
wget https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.14.tar.gz
tar -xvf linux-6.14.tar.gz
rm linux-6.14.tar.gz

echo "Building kernel..."
cd "$LINUX_DIR"
make defconfig
make -j$(nproc)

echo "Preparing initramfs..."

cd "$BUILD_DIR"
wget -q "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION%.*}/releases/x86_64/alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz"
mkdir -p "$ROOTFS_DIR"
tar -xzf "alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz" -C "$ROOTFS_DIR"
rm "alpine-minirootfs-${ALPINE_VERSION}-x86_64.tar.gz"
cd ..

echo "Configuring init script..."
cat > "$ROOTFS_DIR/init" <<EOF
#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mkdir -p /dev/pts
mount -t devpts none /dev/pts

ip link set dev lo up
ip link set dev eth0 up
udhcpc -i eth0

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

echo "qemu-dm-test" > /etc/hostname

mkdir -p /home/workdir
mount -t 9p -o trans=virtio,version=9p2000.L hostshare /home/workdir

echo "Installing packages..."
apk update
apk add util-linux device-mapper

echo "System ready!"

cd home/workdir

exec /sbin/getty -n -l /bin/sh 115200 /dev/console
EOF

chmod +x "$ROOTFS_DIR/init"

echo "Configuring inittab..."
echo "::respawn:/bin/sh" > "$ROOTFS_DIR/etc/inittab"

echo "Building initramfs..."
cd "$ROOTFS_DIR"
find . | cpio -o -H newc | gzip > "$BUILD_DIR/initramfs.tgz"
echo "Setup complete"
