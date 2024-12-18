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

# Configuración de la red WAN (puente)
resource "libvirt_network" "wan" {
  name      = "wan_network"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
}

# Configuración de la red LAN (puente)
resource "libvirt_network" "lan" {
  name      = "lan_network"
  mode      = "bridge"
  bridge    = "br1"
  autostart = true
}

# Pool de almacenamiento
resource "libvirt_pool" "pfsense_pool" {
  name = "pfsense_storage"
  type = "dir"
  target {
    path = var.pfsense_pool_path
  }
}

# Cargar la ISO de pfSense
resource "libvirt_volume" "pfsense_iso" {
  name   = "pfsense_installer.iso"
  pool   = libvirt_pool.pfsense_pool.name
  source = var.pfsense_image
  format = "raw"
}

# Crear el disco para pfSense
resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense_disk.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  format = "qcow2"
  size   = var.pfsense_vm_config.disk_size_gb * 1024 * 1024 * 1024
}

# Máquina virtual para pfSense
resource "libvirt_domain" "pfsense" {
  name   = "pfsense-firewall"
  memory = var.pfsense_vm_config.memory
  vcpu   = var.pfsense_vm_config.cpus

  # Red WAN
  network_interface {
    network_id = libvirt_network.wan.id
    mac        = var.pfsense_vm_config.wan_mac
  }

  # Red LAN
  network_interface {
    network_id = libvirt_network.lan.id
    mac        = var.pfsense_vm_config.lan_mac
  }

  # Disco principal
  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  # Montar la ISO como CD-ROM
  disk {
    volume_id = libvirt_volume.pfsense_iso.id
    scsi      = true
  }

  # Consola gráfica para instalación manual
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  # Consola serial
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  # Configuración de CPU
  cpu {
    mode = "host-passthrough"
  }
}

# Salida de direcciones IP relevantes
output "pfsense_networks" {
  value = {
    wan = var.pfsense_vm_config.wan_ip
    lan = var.pfsense_vm_config.lan_ip
  }
}
