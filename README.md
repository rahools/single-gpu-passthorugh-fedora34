# Single GPU Passthrough Guide [WIP]
VFIO guide for passing my GPU from host to guest VM.

# Introduction
Thanks to contributions by wine and proton, Linux gaming has progressed much more than anyone could have imagined years ago, yet it's not the end. The introduction of the steam deck has once again sparked the interest of big companies like EAC back to native Linux gaming but for the time being, we are stuck with non-borked games, or are we? Luckily for us, with some Linux wizardry, we could boot up a windows VM, pass through our video card to the guest windows, and play games just like that. Additionally, there's an added benefit of running windows only applications like photoshop, office, etc. So if passthrough's so great, why isn't everyone talking about it? Well, there's always a catch, apart from the performance hit as compared to bare metal and difficulty setting up VM, you could be locked from playing your favorite game. Games like R6S, CSGO, Valorant have rigid criteria for what kind of systems are allowed on their service and VMs are not a part of that. It's fair on their part cause that's how developers ensure you and I get an even playing ground on their platform. Thus, if you intend to play games like R6S you should probably check whether they allow KVM players on their platform, if not you're better of with dual booting.

Great! Now with all the pros and cons out of the way, if you're on-board with the idea of GPU passthrough VM: **let's go**.

## My System
- CPU: AMD Ryzen 5 1600
- MoBo: ASUS Prime B350M-A
- GPU: GALAX 1660Ti
- Host OS: Fedora 34 (5.12.15-300.fc34.x86_64)
- Guest OS: Windows 11

## Kudos
Thanks to [risingprismtv](https://youtu.be/3BxAaaRDEEw) for the amazing video guide on the subject and to [wendel from L1Tech](https://forum.level1techs.com/t/fedora-33-ultimiate-vfio-guide-for-2020-2021-wip/163814) for in-depth written guide.

# Prerequisite
This guide assumes that you already have a Windows VM installed with the network, disk, and virtual GPU(spice/QXL) setting already configured and is up and running. Simply put, this guide only focuses on how to configure single GPU passthrough for your VM.

# Passthrough Setting
GPU passthrough works by following these steps before booting up a VM:
- stoping all the processes that are using GPU
- un-loading the driver in use for the GPU
- Reattach GPU from the host
- Passing/Attaching GPU to the guest
- loading appropriate drivers for the guest (VFIO)

Afterward, when you need to claim back resources when you are sone with guests, you can just undo these steps in reverse. As simple as that. But the problem there arises, who will execute these scripts before booting the VM or after shutting down a VM? Luckily for us, libvirt has a utility that can execute a bash script at the start/end of each VM and we can modify this script as per our requirements. So why not start with setting up libvirt hooks.

## Setting up libvirt hooks
Firstly, you need to place the 'hooks' folder in this repo to your libvirt directory which can be found at
> /etc/libvirt/

Next, you need to edit 'kvm.conf' inside the 'hooks' folder and add your GPU IDs, this is done by:
- in a terminal, get the output of '''lspci -knn'''
- find your GPU in the list of GPU devices along with other GPU components such as GPU audio, USB, and serial. Note: only newer generation(GTX 16 and RTX 20 series onwards) models have GPU USB and serial.
- GPU entries will start with a PCI id, eg '09:00.0'
- according to the formatting, change the variables in 'kvm.conf' 

Finally, you would have to edit the hooks itself. In lines:
- 'hooks/qemu.d/win10/prepare/begin/bind_vfio.sh:13'
- 'hooks/qemu.d/win10/release/end/unbind_vfio.sh:44'

you would have to replace 'rahools' with your own local username. This helps the hooks to stop/start the pipewire service, hence handling GPU audio.

**Note**: 
1. If your GPU doesn't have GPU USB and SERIAL, please comment out the lines containing those variables in: 
   - '/hooks/kvm.conf'
   - 'hooks/qemu.d/win10/prepare/begin/bind_vfio.sh'
   - 'hooks/qemu.d/win10/release/end/unbind_vfio.sh'

2. If you use GPU drivers other than Nvidia (AMD or open drivers), you have to specify that in 'hooks/qemu.d/win10/release/end/unbind_vfio.sh'

