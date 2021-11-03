#!/bin/bash

# for debugging
# exec 19>/home/rahools/Desktop/release.log
# BASH_XTRACEFD=19
# set -x

## Load the config file
source "/etc/libvirt/hooks/kvm.conf"

# Unload vfio drievrs
echo $VIRSH_GPU_VIDEO_ID > /sys/bus/pci/devices/$VIRSH_GPU_VIDEO_ID/driver/unbind
echo $VIRSH_GPU_AUDIO_ID > /sys/bus/pci/devices/$VIRSH_GPU_AUDIO_ID/driver/unbind
echo $VIRSH_GPU_USB_ID > /sys/bus/pci/devices/$VIRSH_GPU_USB_ID/driver/unbind
echo $VIRSH_GPU_SERIAL_ID > /sys/bus/pci/devices/$VIRSH_GPU_SERIAL_ID/driver/unbind
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# re-attach gpu back to host
virsh nodedev-reattach $VIRSH_GPU_VIDEO
virsh nodedev-reattach $VIRSH_GPU_AUDIO
virsh nodedev-reattach $VIRSH_GPU_USB
virsh nodedev-reattach $VIRSH_GPU_SERIAL

# avoid race condition
sleep 5

# Rebind VT consoles and EFI
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Load Driver | nvidia driver
modprobe nvidia_drm
modprobe nvidia_modeset
modprobe drm_kms_helper
modprobe nvidia
modprobe i2c_nvidia_gpu
modprobe drm

# Start display services
systemctl start gdm.service
systemctl --machine=rahools@.host --user stop pipewire.socket pipewire.service