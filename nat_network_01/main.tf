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

# 🔌 Configuración de red en bridge
resource "libvirt_network" "br0" {
  name      = var.so_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

# 🗃️ Pool de almacenamiento genérico según rol
resource "libvirt_pool" "volumetmp" {
  name = "${var.cluster_name}_${var.vm_role_name}"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/volumes/${var.cluster_name}_${var.vm_role_name}"
  }
}

# 📦 Imagen base del sistema operativo
resource "libvirt_volume" "so_image" {
  name   = "${var.cluster_name}-so_image"
  source = var.so_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

# ⚙️ Plantillas de configuración por máquina
data "template_file" "vm_configs" {
  for_each = var.vm_rockylinux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")
  vars = {
    ssh_keys       = jsonencode(var.ssh_keys)
    hostname       = each.value.hostname
    short_hostname = each.value.short_hostname
    timezone       = var.timezone
    ip             = each.value.ip
    gateway        = each.value.gateway
    dns1           = each.value.dns1
    dns2           = each.value.dns2
  }
}

# 💽 Disco de cloud-init con config y red
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_rockylinux_definitions

  name           = "${each.key}_cloudinit.iso"
  pool           = libvirt_pool.volumetmp.name
  user_data      = data.template_file.vm_configs[each.key].rendered
  network_config = templatefile("${path.module}/config/network-config.tpl", {
    ip      = each.value.ip
    gateway = each.value.gateway
    dns1    = each.value.dns1
    dns2    = each.value.dns2
  })
}

# 💾 Disco raíz de cada VM
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_rockylinux_definitions

  name           = each.value.volume_name
  base_volume_id = libvirt_volume.so_image.id
  pool           = libvirt_pool.volumetmp.name
  format         = each.value.volume_format
  size           = each.value.volume_size * 1024 * 1024 * 1024
}

# 🖥️ Máquina virtual
resource "libvirt_domain" "vm" {
  for_each = var.vm_rockylinux_definitions

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.cpus

  network_interface {
    network_id = libvirt_network.br0.id
    addresses  = [each.value.ip]
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

# 📤 IPs generadas
output "vm_ip_addresses" {
  value = { for vm, config in var.vm_rockylinux_definitions : vm => config.ip }
}