# Defining pool
#https://sysguides.com/create-and-manage-storage-pools-and-volumes-in-kvm/

resource "libvirt_pool" "ubuntu_cluster" {
  name = "ubuntu_cluster"
  type = "dir"
  path = "/var/lib/libvirt/pools/ubuntu"
}

# Defining VM Volume
#fetch the latest ubuntu release image from their mirrors.
#when using cloud-images not allowed to increase disk-size
#only on localy downloaded image with command:
#qemu-img resize images/focal-server-cloudimg-amd64-disk-kvm.img 10G
#Tip:
#when provisioning multiple domains using the same base image, 
#create a libvirt_volume for the base image and then define the domain specific ones as based on it.
resource "libvirt_volume" "ubuntu_image" {
  name = "ubuntu_image"
  pool = libvirt_pool.ubuntu_cluster.name # List storage pools using virsh pool-list
  source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu_volume" {
  count = length(var.hostname)
  name = "ubuntu_volume.${var.hostname[count.index]}"
  pool = libvirt_pool.ubuntu_cluster.name # List storage pools using virsh pool-list
  base_volume_id = libvirt_volume.ubuntu_image.id
  size = var.sizeBytes
  format = "qcow2"
}

# Use CloudInit ISO to add ssh-key to the instance

data "template_file" "user_data" {
  count = length(var.hostname)
  template = file("${path.module}/files/userdata.yaml")
  vars = {
    hostname = element(var.hostname, count.index)
    fqdn = "${var.hostname[count.index]}.${var.domain}"
    ssh_authorized_keys = file("${path.module}/files/kvm-k8s-cluster.pub")
  } 
}

data "template_file" "network_config" {
  template = file("${path.module}/files/network_config.yaml")
}

# for more info about paramater check this out
# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
# Use CloudInit to add our ssh-key to the instance
# you can add also meta_data field
resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.hostname)
  name = "commoninit.${var.hostname[count.index]}.iso"
  user_data = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool = libvirt_pool.ubuntu_cluster.name
}

# Define KVM domain to create
resource "libvirt_domain" "domain_ubuntu" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk {
    volume_id = element(libvirt_volume.ubuntu_volume.*.id, count.index)
  }

  network_interface {
    network_name = "default" # List networks with virsh net-list
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
# show IP, run 'terraform refresh' if not populated
output "ip" {
  value = libvirt_domain.domain_ubuntu.*.network_interface.0.addresses
}
