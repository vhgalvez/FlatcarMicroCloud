# pfsense\main.tf
terraform {
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

resource "libvirt_pool" "pfsense_pool" {
  name = "pfsense-pool"
  type = "dir"
  target {
    path = var.pfsense_pool_path
  }
}

resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  source = var.pfsense_image
  format = "qcow2"
}

resource "libvirt_domain" "pfsense_vm" {
  name   = var.pfsense_vm_name
  memory = var.pfsense_vm_config.memory
  vcpu   = var.pfsense_vm_config.cpus

  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  network_interface {
    bridge = "br0" # WAN
  }

  network_interface {
    bridge = "br1" # LAN
  }

  boot_device {
    dev = ["hd"]
  }

  graphics {
    type           = "vnc"
    listen_address = "0.0.0.0"
    listen_type    = "address"
  }
}
