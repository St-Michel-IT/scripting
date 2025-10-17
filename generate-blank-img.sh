#!/usr/bin/bash
# Dependencies are
# sudo apt-get update && sudo apt-get install -y qemu-system-x86 cloud-image-utils wget openssh-client

# Inspired by https://levelup.gitconnected.com/boot-an-ubuntu-cloud-image-with-qemu-c42c77cf92cc
# and https://powersj.io/posts/ubuntu-qemu-cli/
# Image downloaded from https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img
# 2024-10-21 23:04  230M  QCow2 UEFI/GPT Bootable disk image
readonly TEMPLATE_IMAGE="ubuntu-24.04-minimal-cloudimg-amd64.img"
readonly VM_PATH="/home/chrichri/vms"
readonly TEMPLATE_PATH="$VM_PATH/$TEMPLATE_IMAGE"
readonly SEED="seed.img"
readonly SIZE="4G"
readonly META_DATA="meta-data.yaml"

# Define an image name
function image_fine_name() {
    echo "ubuntu-24.04-minimal-cloudimg-amd64-instance-$1.qcow2"
}
INSTANCE_NUMBER=$RANDOM
IMAGE=$(image_fine_name $INSTANCE_NUMBER)
IMAGE_PATH="$VM_PATH/$IMAGE"
while [ -e "$IMAGE_PATH" ]; do
    echo "Generating a new image name"
    INSTANCE_NUMBER=$RANDOM
    IMAGE=$(image_fine_name $INSTANCE_NUMBER)
    IMAGE_PATH="$VM_PATH/$IMAGE"
done
echo "Creating image at path: $IMAGE_PATH"

# Check if the image exists
if [ ! -f $TEMPLATE_PATH ]; then
    echo "Image not found, downloading..."
    wget -P "$VM_PATH" "https://cloud-images.ubuntu.com/minimal/releases/noble/release/$TEMPLATE_IMAGE"
fi
# Copy template to image
cp "$TEMPLATE_PATH" "$IMAGE_PATH"

# Resize the image
qemu-img resize "$IMAGE_PATH" $SIZE

# Tries to add the SSH key identity using the agent
ssh-add id_ed25519_ubuntu_init

# Modify meta-data
sed -i "s/instance-id: .*/instance-id: $INSTANCE_NUMBER/" $META_DATA
sed -i "s/local-hostname: .*/local-hostname: $INSTANCE_NUMBER.local/" $META_DATA


# Generate the seed
cloud-localds "$SEED" user-data.yaml $META_DATA

# Start first connection
qemu-system-x86_64 \
 -machine accel=kvm,type=q35 \
 -smp 1 \
 -m 512M \
 -nographic \
 -device virtio-net-pci,netdev=net0 \
 -netdev user,id=net0,hostfwd=tcp::2223-:22 \
 -drive if=virtio,format=qcow2,file="$IMAGE_PATH" \
 -drive if=virtio,format=raw,file="$SEED"