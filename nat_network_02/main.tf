# nat_network_02\main.tf
terraform {
  required_version = "= 1.9.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Crea el directorio para el pool si no existe
resource "null_resource" "create_pool_directory" {
  provisioner "local-exec" {
    command = "sudo mkdir -p /mnt/lv_data/organized_storage/volumes/${var.cluster_name}_bastion && sudo chown qemu:qemu /mnt/lv_data/organized_storage/volumes/${var.cluster_name}_bastion"
  }
}

# Define el pool después de crear el directorio
resource "libvirt_pool" "volumetmp_bastion" {
  depends_on = [null_resource.create_pool_directory]

  name = "${var.cluster_name}_bastion"
  type = "dir"

  target {
    path = "/mnt/lv_data/organized_storage/volumes/${var.cluster_name}_bastion"
  }
}

# Define el volumen de la imagen base
resource "libvirt_volume" "rocky9_image" {
  depends_on = [libvirt_pool.volumetmp_bastion]

  name   = "${var.cluster_name}_rocky9_image"
  source = var.rocky9_image
  pool   = libvirt_pool.volumetmp_bastion.name
  format = "qcow2"
}

# Define las máquinas virtuales
resource "libvirt_domain" "vm" {
  for_each = var.vm_rockylinux_definitions

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.cpus

  network_interface {
    network_id     = libvirt_network.kube_network_02.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.vm_cloudinit[each.key].id

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  cpu {
    mode = "host-passthrough"
  }
}

# Define la red
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}
