# nat_network_02\main.tf
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

#  Red NAT principal para la red de servicio
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  bridge    = "virbr_kube02"
  domain    = "kube.internal"
  autostart = true
  addresses = ["10.17.3.0/24"]

  dhcp {
    enabled = true
  }
}


#  Pool de almacenamiento
resource "libvirt_pool" "volumetmp_nat_02" {
  name = "${var.cluster_name}_nat_02"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/volumes/${var.cluster_name}_nat_02"
  }
}

#  Imagen base del sistema
resource "libvirt_volume" "rocky9_image" {
  name   = "${var.cluster_name}_rocky9_image"
  source = var.rocky9_image
  pool   = libvirt_pool.volumetmp_nat_02.name
  format = "qcow2"
}

#  User-data por VM
data "template_file" "vm-configs" {
  for_each = var.vm_rockylinux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")
  vars = {
    ssh_keys       = jsonencode(var.ssh_keys)
    hostname       = each.value.hostname
    short_hostname = each.value.short_hostname
    timezone       = var.timezone
    ip             = each.value.ip
    ipvip          = each.value.ipvip
    gateway        = var.gateway
    dns1           = var.dns1
    dns2           = var.dns2
    cluster_domain = var.cluster_domain
  }
}

#  Cloud-init por VM
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_rockylinux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp_nat_02.name
  user_data = data.template_file.vm-configs[each.key].rendered
}

#  Disco raíz por VM
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_rockylinux_definitions

  name           = "${each.key}-${var.cluster_name}.qcow2"
  base_volume_id = libvirt_volume.rocky9_image.id
  pool           = libvirt_pool.volumetmp_nat_02.name
  format         = "qcow2"
}

#  Definición de VMs
resource "libvirt_domain" "vm_nat_02" {
  for_each = var.vm_rockylinux_definitions

  name   = each.key
  memory = each.value.domain_memory
  vcpu   = each.value.cpus

  arch    = "x86_64"
  machine = "pc"

  # Conexión NAT (red de servicio)
  network_interface {
    network_id = libvirt_network.kube_network_02.id
    addresses  = [each.value.ip]
  }

  # Conexión br-vip (no se crea aquí, solo se usa)
  network_interface {
    addresses = [each.value.ipvip]
    bridge    = "br-vip"
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

#  Mostrar IPs asignadas
output "ip_addresses" {
  value = {
    for key, machine in libvirt_domain.vm_nat_02 :
    key => var.vm_rockylinux_definitions[key].ip
  }
}