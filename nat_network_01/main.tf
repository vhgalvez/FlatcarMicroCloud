# br0_network\main.tf
terraform {
  required_version = ">= 1.11.3, < 2.0.0"
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

# Configuración de la red br0
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "nat"
  autostart = true
  addresses = ["10.17.5.0/24"]
}

# Configuración del pool de almacenamiento
resource "libvirt_pool" "volumetmp_k8s-api-lb" {
  name = "${var.cluster_name}_k8s-api-lb"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/volumes/${var.cluster_name}_k8s-api-lb"
  }
}

# Configuración del volumen de la imagen de Rocky Linux
resource "libvirt_volume" "rocky9_image" {
  name   = "${var.cluster_name}-rocky9_image"
  source = var.rocky9_image
  pool   = libvirt_pool.volumetmp_k8s-api-lb.name # Usando el pool correcto
  format = "qcow2"
}

# Configuración de los archivos de configuración para cada VM
data "template_file" "vm_configs" {
  for_each = var.vm_rockylinux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")
  vars = {
    ssh_keys       = jsonencode(var.ssh_keys),
    hostname       = each.value.hostname,
    short_hostname = each.value.short_hostname,
    timezone       = var.timezone,
    ip             = each.value.ip,
    gateway        = each.value.gateway,
    dns1           = each.value.dns1,
    dns2           = each.value.dns2
  }
}

# Configuración de los discos de CloudInit
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_rockylinux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp_k8s-api-lb.name # Usando el pool correcto
  user_data = data.template_file.vm_configs[each.key].rendered
  network_config = templatefile("${path.module}/config/network-config.tpl", {
    ip      = each.value.ip,
    gateway = each.value.gateway,
    dns1    = each.value.dns1,
    dns2    = each.value.dns2
  })
}

# Configuración de los discos de las máquinas virtuales
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_rockylinux_definitions

  name           = each.value.volume_name
  base_volume_id = libvirt_volume.rocky9_image.id
  pool           = libvirt_pool.volumetmp_k8s-api-lb.name # Usando el pool correcto
  format         = each.value.volume_format
  size           = each.value.volume_size * 1024 * 1024 * 1024 # Convierte GB a bytes
}

# Configuración de las máquinas virtuales (VMs)
resource "libvirt_domain" "vm" {
  for_each = var.vm_rockylinux_definitions

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.cpus

  network_interface {
    network_id = libvirt_network.br0.id
    addresses  = [each.value.ip] # Asignar la IP estática
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

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  cpu {
    mode = "host-passthrough"
  }
}

# Salida de las IPs de las máquinas virtuales
output "vm_ip_addresses" {
  value = { for vm, config in var.vm_rockylinux_definitions : vm => config.ip }
}
