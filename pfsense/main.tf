# pfsense\main.tf
terraform {
  required_version = "= 1.10.1"

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

provider "libvirt" {
  uri = "qemu:///system"  # Asegúrate de que tu máquina virtual esté ejecutándose en este URI
}

provider "pfsense" {
  hostname = "https://192.168.0.1"  # IP de pfSense
  username = "admin"
  password = "pfsense"
  insecure = true                  # Permite conexiones HTTPS no verificadas
}

resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense.qcow2"
  pool   = var.pfsense_pool_path
  source = var.pfsense_image
  format = "qcow2"
}

resource "libvirt_domain" "pfsense_vm" {
  name   = "pfsense"
  memory = var.pfsense_vm_config.memory
  vcpu   = var.pfsense_vm_config.cpus

  # Disco principal
  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  # Interfaz WAN
  network_interface {
    bridge = "br0"  # Asegúrate de tener el puente br0 configurado para la WAN
  }

  # Interfaz LAN
  network_interface {
    bridge = "br1"  # Asegúrate de tener el puente br1 configurado para la LAN
  }

  # Configuración de arranque
  boot_device {
    dev = ["hd"]
  }

  graphics {
    type            = "vnc"
    listen_address  = "0.0.0.0"
    listen_type     = "address"
  }

  # Configuración de la dirección IP de la LAN y WAN
  provisioner "remote-exec" {
    inline = [
      "echo 'LAN IP: ${var.lan_ip}'",
      "echo 'WAN IP: ${var.wan_ip}'"
    ]
  }
}

output "pfSense_ip" {
  value = "http://${libvirt_domain.pfsense_vm.network_interface[1].address}:80"
}
