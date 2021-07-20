#!/bin/bash

# for debugging
# exec 19>/home/rahools/Desktop/startlogfile
# BASH_XTRACEFD=19
# set -x

# Load the config file
source "/etc/libvirt/hooks/kvm.conf"

# stop Hhst from using GPU
systemctl stop gdm.service

# un-bind VTconsole and EFI
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# un-bind drivers
echo $VIRSH_GPU_VIDEO_ID > /sys/bus/pci/devices/$VIRSH_GPU_VIDEO_ID/driver/unbind
echo $VIRSH_GPU_AUDIO_ID > /sys/bus/pci/devices/$VIRSH_GPU_AUDIO_ID/driver/unbind
echo $VIRSH_GPU_USB_ID > /sys/bus/pci/devices/$VIRSH_GPU_USB_ID/driver/unbind
echo $VIRSH_GPU_SERIAL_ID > /sys/bus/pci/devices/$VIRSH_GPU_SERIAL_ID/driver/unbind

# avoid race condition
sleep 5

# deattach GPU from host
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach $VIRSH_GPU_USB
virsh nodedev-detach $VIRSH_GPU_SERIAL

# bind VFIO drivers
modprobe vfio_pci
modprobe vfio_iommu_type1
modprobe vfio
