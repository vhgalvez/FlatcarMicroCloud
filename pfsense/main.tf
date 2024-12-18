# Requerimientos de Terraform
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
    pfsense = {
      source  = "marshallford/pfsense"
      version = "0.7.2"
    }
  }
}

# Configuración de libvirt
provider "libvirt" {
  uri = "qemu:///system"
}


# Configuración de la red WAN
resource "libvirt_network" "wan" {
  name   = "wan_network"
  mode   = "bridge"
  bridge = "br0"
}

# Configuración de la red LAN
resource "libvirt_network" "lan" {
  name   = "lan_network"
  mode   = "bridge"
  bridge = "br1"
}

# Pool de almacenamiento para pfSense
resource "libvirt_pool" "pfsense_pool" {
  name = "pfsense_storage"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images"
  }
}

# Cargar la ISO de pfSense
resource "libvirt_volume" "pfsense_iso" {
  name   = "pfsense_installer.iso"
  pool   = libvirt_pool.pfsense_pool.name
  source = "/ruta/a/la/iso/pfsense.iso" # Reemplaza con la ruta correcta
  format = "raw"
}

# Disco principal para pfSense
resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense_disk.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  format = "qcow2"
  size   = 20 * 1024 * 1024 * 1024
}

# Máquina virtual de pfSense
resource "libvirt_domain" "pfsense" {
  name   = "pfsense-firewall"
  memory = 2048
  vcpu   = 2

  # Configuración de interfaces de red
  network_interface {
    network_id = libvirt_network.wan.id
    mac        = "52:54:00:11:22:33"
  }

  network_interface {
    network_id = libvirt_network.lan.id
    mac        = "52:54:00:44:55:66"
  }

  # Disco de instalación
  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  disk {
    volume_id = libvirt_volume.pfsense_iso.id
    scsi      = true
    readonly  = true
  }

  # Dispositivo de arranque
  boot_device {
    dev = ["cdrom", "hd"]
  }

  # Configuración de gráficos (acceso VNC)
  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}
