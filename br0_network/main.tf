# br0_network\main.tf
terraform {
  required_version = "= 1.9.6"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

resource "libvirt_pool" "volumetmp_bastion" {
  name = "${var.cluster_name}_bastion"
  type = "dir"
  path = "/mnt/lv_data/organized_storage/volumes/${var.cluster_name}_bastion"
}

resource "libvirt_volume" "rocky9_image" {
  name   = "${var.cluster_name}-rocky9_image"
  source = var.rocky9_image
  pool   = libvirt_pool.volumetmp_bastion.name
  format = "qcow2"
}

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

resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_rockylinux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp_bastion.name
  user_data = data.template_file.vm_configs[each.key].rendered
  network_config = templatefile("${path.module}/config/network-config.tpl", {
    ip      = each.value.ip,
    gateway = each.value.gateway,
    dns1    = each.value.dns1,
    dns2    = each.value.dns2
  })
}

resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_rockylinux_definitions

  name           = each.value.volume_name
  base_volume_id = libvirt_volume.rocky9_image.id
  pool           = each.value.volume_pool
  format         = each.value.volume_format
  size           = each.value.volume_size
}

resource "libvirt_domain" "vm" {
  for_each = var.vm_rockylinux_definitions

  name   = each.value.hostname
  memory = each.value.memory
  vcpu   = each.value.cpus

  network_interface {
    network_id = libvirt_network.br0.id
    bridge     = "br0"
    addresses  = [each.value.ip] # Assign the static IP
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

output "bastion_ip_address" {
  value = var.vm_rockylinux_definitions["bastion1"].ip
}