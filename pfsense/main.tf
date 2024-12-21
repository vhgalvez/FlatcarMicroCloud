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

# Definición del pool de almacenamiento
resource "libvirt_pool" "pfsense_pool" {
  name = "pfsense-pool"
  type = "dir"
  target {
    path = var.pfsense_pool_path
  }
}

# Creación del volumen para la VM
resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  source = var.pfsense_image
  format = "qcow2"
}

# Configuración de la máquina virtual
resource "libvirt_domain" "pfsense_vm" {
  name   = var.pfsense_vm_name
  memory = var.pfsense_vm_config.memory
  vcpu   = var.pfsense_vm_config.cpus

  # Disco
  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  # Interfaz WAN
  network_interface {
    bridge = "br0" # WAN
    xml    = <<-EOF
      <interface type='bridge'>
        <mac address='52:54:00:11:22:33'/>
        <source bridge='br0'/>
        <model type='virtio'/>
      </interface>
    EOF
  }

  # Interfaz LAN
  network_interface {
    bridge = "br1" # LAN
    xml    = <<-EOF
      <interface type='bridge'>
        <mac address='52:54:00:44:55:66'/>
        <source bridge='br1'/>
        <model type='virtio'/>
      </interface>
    EOF
  }

  # Configuración del dispositivo de arranque
  boot_device {
    dev = ["hd"]
  }

  # Configuración de gráficos (opcional)
  graphics {
    type           = "vnc"
    listen_address = "0.0.0.0"
    listen_type    = "address"
  }
}

# Salidas para las direcciones IP de WAN y LAN
output "pfSense_WAN_IP" {
  value = "http://${var.wan_ip}:80"
}

output "pfSense_LAN_IP" {
  value = "http://${var.lan_ip}:80"
}
