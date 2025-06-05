# nat_network_LB\main.tf
terraform {
  required_version = ">= 1.11.4, < 2.0.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# 🔌 Red puenteada LAN (br0 físico)
resource "libvirt_network" "br0" {
  name      = var.so_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

# 📦 Pool de almacenamiento
resource "libvirt_pool" "volumetmp_NET_LB" {
  name = "${var.cluster_name}_NET_LB"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/volumes/${var.cluster_name}_NET_LB"
  }
}

# 📀 Imagen base del sistema operativo
resource "libvirt_volume" "so_image" {
  name   = "${var.cluster_name}_so_image"
  source = var.so_image
  pool   = libvirt_pool.volumetmp_NET_LB.name
  format = "qcow2"
}

# 📝 Cloud-init (user-data) por VM
data "template_file" "vm-configs" {
  for_each = var.vm_linux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")
  vars = {
    ssh_keys       = jsonencode(var.ssh_keys)
    hostname       = each.value.hostname
    short_hostname = each.value.short_hostname
    timezone       = var.timezone
    ip             = each.value.ip
    mac            = each.value.mac
    gateway        = each.value.gateway
    dns1           = each.value.dns1
    dns2           = each.value.dns2
    cluster_domain = var.cluster_domain
  }
}

# 📁 Disco cloud-init
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_linux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp_NET_LB.name
  user_data = data.template_file.vm-configs[each.key].rendered
}

# 📆 Disco raíz por VM
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_linux_definitions

  name           = "${each.key}-${var.cluster_name}.qcow2"
  base_volume_id = libvirt_volume.so_image.id
  pool           = libvirt_pool.volumetmp_NET_LB.name
  format         = "qcow2"
}

# 🖥️ Definición de VM
resource "libvirt_domain" "vm_NET_LB" {
  for_each = var.vm_linux_definitions

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.cpus

  arch    = "x86_64"
  machine = "pc"

  network_interface {
    network_name = var.so_network_name
    addresses    = [each.value.ip]
    mac          = each.value.mac
  }

  # 🔁 NIC #2: br0 (LAN real)
  network_interface {
    bridge    = "br0"
    addresses = [each.value.ip_lan]
    mac       = each.value.mac_lan
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.vm_cloudinit[each.key].id

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  cpu {
    mode = "host-model"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# 🌐 Mostrar IPs asignadas
output "ip_addresses" {
  value = {
    for key, machine in libvirt_domain.vm_NET_LB :
    key => {
      ip_nat = var.vm_linux_definitions[key].ip
      ip_lan = var.vm_linux_definitions[key].ip_lan
    }
  }
}
