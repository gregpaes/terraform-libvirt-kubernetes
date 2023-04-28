# terraform-libvirt-kubernetes

## About this repo

This repo is a study case about "How To Provision VMs on KVM with Terraform"

Refer this link for documentation: https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/

A lot of efort and troubleshooting research in this journey

Terraform script for KVM that creates multiple Virtual Machines simultaneously on on your laptop:
https://medium.com/@krasnosvar/terraform-script-for-kvm-that-creates-multiple-virtual-machines-simultaneously-942832f9ebda

Terraform to Create a Ubuntu 22.04 VM in VMware vSphere ESXi:
https://tekanaid.com/posts/terraform-create-ubuntu22-04-vm-vmware-vsphere

How to Create and Manage Storage Pools and Volumes in KVM Virtualization:
https://sysguides.com/create-and-manage-storage-pools-and-volumes-in-kvm/

github / dmacvicar / terraform-provider-libvirt / examples / ubuntu:
https://github.com/dmacvicar/terraform-provider-libvirt/tree/main/examples/v0.13/ubuntu

Best practices for using Terraform:
https://cloud.google.com/docs/terraform/best-practices-for-terraform#helper-scripts

```Defining VM Volume
fetch the latest ubuntu release image from their mirrors.
when using cloud-images not allowed to increase disk-size
only on localy downloaded image with command:
qemu-img resize images/focal-server-cloudimg-amd64-disk-kvm.img 10G
Tip:
when provisioning multiple domains using the same base image,
create a libvirt_volume for the base image and then define the domain specific ones as based on it.??
https://registry.terraform.io/providers/multani/libvirt/latest/docs/resources/volume
```

https://github.com/ptsgr/terraform-libvirt-kubernetes

libvirt-k8s-provisioner - Automate your cluster provisioning from 0 to k8s:
https://github.com/kubealex/libvirt-k8s-provisioner
 
