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

# Configuración del proveedor libvirt para gestionar la VM
provider "libvirt" {
  uri = "qemu:///system"
}

# Configuración inicial del proveedor pfSense
provider "pfsense" {
  depends_on = [libvirt_domain.pfsense_vm] # Asegura que pfSense VM esté creada
  hostname   = "https://${var.wan_ip}"    # Dirección IP inicial de WAN
  username   = "admin"
  password   = "pfsense"
  insecure   = true
}

# Crear directorio de almacenamiento si no existe
resource "null_resource" "create_directory" {
  provisioner "local-exec" {
    command = "mkdir -p ${var.pfsense_pool_path} && chown libvirt-qemu:kvm ${var.pfsense_pool_path} && chmod 775 ${var.pfsense_pool_path}"
  }
  triggers = {
    always_run = timestamp()
  }
}

# Configuración del pool de almacenamiento
resource "libvirt_pool" "pfsense_pool" {
  depends_on = [null_resource.create_directory]
  name       = "pfsense-pool"
  type       = "dir"
  target {
    path = var.pfsense_pool_path
  }
}

# Crear el volumen para pfSense
resource "libvirt_volume" "pfsense_disk" {
  name   = "pfsense.qcow2"
  pool   = libvirt_pool.pfsense_pool.name
  source = var.pfsense_image
  format = "qcow2"
}

# Crear la máquina virtual de pfSense
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
    bridge = "br0"
  }

  # Interfaz LAN
  network_interface {
    bridge = "br1"
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
}

# Configuración de VLANs usando el proveedor pfSense
resource "pfsense_vlan" "vlan10" {
  depends_on       = [libvirt_domain.pfsense_vm]
  parent_interface = "br1"
  vlan_tag         = 10
  description      = "VLAN 10 (Management)"
}

resource "pfsense_vlan" "vlan20" {
  depends_on       = [libvirt_domain.pfsense_vm]
  parent_interface = "br1"
  vlan_tag         = 20
  description      = "VLAN 20 (Clients)"
}

resource "pfsense_vlan" "vlan30" {
  depends_on       = [libvirt_domain.pfsense_vm]
  parent_interface = "br1"
  vlan_tag         = 30
  description      = "VLAN 30 (IoT)"
}

# Salidas
output "pfSense_WAN_IP" {
  value = "http://${var.wan_ip}:80"
}

output "pfSense_LAN_IP" {
  value = "http://${var.lan_ip}:80"
}
