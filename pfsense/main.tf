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
  uri = "qemu:///system" # Asegúrate de que tu máquina virtual esté ejecutándose en este URI
}

provider "pfsense" {
  hostname = "https://192.168.0.1" # IP de pfSense
  username = "admin"
  password = "pfsense"
  insecure = true # Permite conexiones HTTPS no verificadas
}

# Crear el directorio si no existe
resource "null_resource" "create_directory" {
  provisioner "local-exec" {
    command = "mkdir -p /mnt/lv_data/organized_storage/volumes/pfsense && chown libvirt-qemu:kvm /mnt/lv_data/organized_storage/volumes/pfsense && chmod 775 /mnt/lv_data/organized_storage/volumes/pfsense"
  }
  triggers = {
    always_run = timestamp()
  }
}

# Configuración del pool de almacenamiento
resource "libvirt_pool" "pfsense_pool" {
  depends_on = [null_resource.create_directory] # Asegura que el directorio exista
  name       = "pfsense-pool"
  type       = "dir"
  target {
    path = "/mnt/lv_data/organized_storage/volumes/pfsense"
  }
}

# Crear el volumen para pfSense
resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
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
    bridge = "br0" # Asegúrate de tener el puente br0 configurado para la WAN
  }

  # Interfaz LAN
  network_interface {
    bridge = "br1" # Asegúrate de tener el puente br1 configurado para la LAN
  }

  # Configuración de arranque
  boot_device {
    dev = ["hd"]
  }

  graphics {
    type           = "vnc"
    listen_address = "0.0.0.0"
    listen_type    = "address"
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
  value = "http://${libvirt_domain.pfsense_vm.network_interface[1].addresses[0]}:80"
}
