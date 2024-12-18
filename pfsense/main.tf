# pfsense\main.tf
terraform {
  required_version = ">= 1.4.0"

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

resource "libvirt_network" "wan" {
  name   = "wan_network"
  mode   = "bridge"
  bridge = "br0"
}

resource "libvirt_network" "lan" {
  name   = "lan_network"
  mode   = "bridge"
  bridge = "br1"
}

resource "libvirt_pool" "pfsense_pool" {
  name = "pfsense_storage"
  type = "dir"
  target {
    path = var.pfsense_pool_path
  }
}

resource "libvirt_volume" "pfsense_iso" {
  name   = "pfsense_installer.iso"
  pool   = libvirt_pool.pfsense_pool.name
  source = var.pfsense_image
  format = "iso"
}

resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense_disk.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  format = "qcow2"
  size   = var.pfsense_vm_config.disk_size_gb * 1024 * 1024 * 1024
}

resource "libvirt_domain" "pfsense" {
  name   = "pfsense-firewall"
  memory = var.pfsense_vm_config.memory
  vcpu   = var.pfsense_vm_config.cpus

  network_interface {
    network_id = libvirt_network.wan.id
    mac        = var.pfsense_vm_config.wan_mac
  }

  network_interface {
    network_id = libvirt_network.lan.id
    mac        = var.pfsense_vm_config.lan_mac
  }

  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  disk {
    volume_id = libvirt_volume.pfsense_iso.id
    scsi      = true
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
