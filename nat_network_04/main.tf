# br0_network/main.tf

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

# 🔌 Red principal puenteada hacia LAN (br0)
resource "libvirt_network" "br0" {
  name      = var.so_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

# 🔌 Red puenteada interna para tráfico VIP (br-vip)
resource "libvirt_network" "br_vip" {
  name      = "br-vip"
  mode      = "bridge"
  bridge    = "br-vip"
  autostart = true
  addresses = ["10.17.5.0/24"]
}

# 📦 Pool temporal de volúmenes
resource "libvirt_pool" "volumetmp" {
  name = "volumetmp_${var.vm_role_name}"
  type = "dir"

  target {
    path = "/var/lib/libvirt/images/volumes/volumetmp_${var.vm_role_name}"
  }
}

# 📦 Imagen base del sistema operativo
resource "libvirt_volume" "so_image" {
  name   = "${var.cluster_name}-so_image"
  source = var.so_image
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

# 📄 Plantilla cloud-init renderizada por máquina
data "template_file" "vm_configs" {
  for_each = var.vm_linux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")

  vars = {
    ssh_keys       = join("\n", var.ssh_keys)
    cluster_name   = var.cluster_name
    cluster_domain = var.cluster_domain
    hostname       = each.value.hostname
    short_hostname = each.value.short_hostname
    timezone       = var.timezone
    role_name      = var.vm_role_name
    ip             = each.value.ip
    ipvip          = each.value.ipvip
    gateway        = each.value.gateway
    dns1           = each.value.dns1
    dns2           = each.value.dns2
    host_ip        = var.host_ip
  }
}

# 💿 Disco cloud-init con config y red
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_linux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp.name
  user_data = data.template_file.vm_configs[each.key].rendered

  # Opcional, si usas archivos .nmconnection no es imprescindible
  network_config = templatefile("${path.module}/config/network-config.tpl", {
    ip      = each.value.ip
    ipvip   = each.value.ipvip
    gateway = each.value.gateway
    dns1    = each.value.dns1
    dns2    = each.value.dns2
  })
}

# 📦 Disco raíz personalizado por máquina
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_linux_definitions

  name           = each.value.volume_name
  base_volume_id = libvirt_volume.so_image.id
  pool           = libvirt_pool.volumetmp.name
  format         = each.value.volume_format
  size           = each.value.volume_size * 1024 * 1024 * 1024
}

# 🖥️ Máquina virtual completa
resource "libvirt_domain" "vm" {
  for_each = var.vm_linux_definitions

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.cpus

  # NIC principal conectada a la LAN
  network_interface {
    bridge    = "br0"
    addresses = [each.value.ip]
    mac       = each.value.mac
  }

  # NIC secundaria para Keepalived VIPs
  network_interface {
    bridge    = "br-vip"
    addresses = [each.value.ipvip]
  }
  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  cloudinit = libvirt_cloudinit_disk.vm_cloudinit[each.key].id

  boot_device {
    dev = ["hd"]
  }

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

# 🔎 Salida de IPs por VM
output "vm_ip_addresses" {
  value = { for vm, config in var.vm_linux_definitions : vm => config.ip }
}