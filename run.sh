#!/bin/bash
ROOTFS_DIR=${ROOTFS_DIR:-rootfs}
sudo qemu-system-x86_64                 \
    -accel tcg,thread=multi             \
    -smp 2                              \
    -m 2G                               \
    -nographic                          \
    -kernel linux/arch/x86/boot/bzImage \
    -virtfs local,path=${ROOTFS_DIR},mount_tag=rootfs,security_model=passthrough,id=rootfs,multidevs=remap \
    -append "root=rootfs rootfstype=9p rootflags=trans=virtio,version=9p2000.L rw console=ttyS0 init=/sbin/init debug loglevel=8 ignore_loglevel"
