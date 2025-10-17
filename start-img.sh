#!/usr/bin/bash
# Dependencies are
# sudo apt-get update && sudo apt-get install -y qemu-system-x86 wget openssh-client
# Verify the number of arguments, should be one
if [ "$#" -ne 1 ]; then
    echo "One and only one argument, usage is: $0 <image path>"
    exit 1
fi

# Check if the image exists
if [ ! -f $1 ]; then
    echo "Image $1 not found"
    exit 1
fi

# Connect
qemu-system-x86_64 \
 -machine accel=kvm,type=q35 \
 -smp 1 \
 -m 512M \
 -nographic \
 -device virtio-net-pci,netdev=net0 \
 -netdev user,id=net0,hostfwd=tcp::2223-:22 \
 -drive if=virtio,format=qcow2,file="$1"