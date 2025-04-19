# nat_network_03\main.tf
terraform {
  required_version = ">= 1.11.4, < 2.0.0"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
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

provider "ct" {}

# 🧩 Definición de la red NAT sin adaptador puente
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  bridge    = "virbr3"
  domain    = "kube.internal"
  autostart = true
  addresses = ["10.17.4.0/24"]

  dhcp {
    enabled = true
    range_start = "10.17.4.100"
    range_end   = "10.17.4.254"
  }
}



# 🗂️ Definición del pool de almacenamiento
resource "libvirt_pool" "volumetmp_flatcar_03" {
  name = "volumetmp_flatcar_03"
  type = "dir"
  target {
    path = "/var/lib/libvirt/images/volumes/volumetmp_flatcar_03"
  }
}

# 📦 Volumen base
resource "libvirt_volume" "base" {
  name   = "base"
  source = var.base_image
  pool   = libvirt_pool.volumetmp_flatcar_03.name
  format = "qcow2"
}

# 📄 Generación de archivos de configuración para las VMs
data "template_file" "vm-configs" {
  for_each = var.vm_definitions

  template = file("${path.module}/configs/machine-${each.key}-config.yaml.tmpl")

  vars = {
    ssh_keys  = join(",", var.ssh_keys)
    node_name = each.value.node_name
    ip        = each.value.ip
    host_name = each.value.name_dominio
    gateway   = var.gateway
    dns1      = var.dns1
    dns2      = var.dns2
    timezone  = var.timezone
  }
}

# 🔧 Generación de configuraciones Ignition
data "ct_config" "vm-ignitions" {
  for_each = var.vm_definitions
  content  = data.template_file.vm-configs[each.key].rendered
}

# 💾 Guardar configuraciones Ignition localmente
resource "local_file" "ignition_configs" {
  for_each = var.vm_definitions

  content  = data.ct_config.vm-ignitions[each.key].rendered
  filename = "${path.module}/ignition-configs/${each.key}.ign"
}

# 🔌 Configuración de Ignition en libvirt
resource "libvirt_ignition" "ignition" {
  for_each = var.vm_definitions

  name    = "${each.key}-ignition"
  pool    = libvirt_pool.volumetmp_flatcar_03.name
  content = data.ct_config.vm-ignitions[each.key].rendered
}

# 💽 Volúmenes para las VMs
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_definitions

  name           = "${each.key}-disk"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp_flatcar_03.name
  format         = "qcow2"
  size           = each.value.disk_size * 1024 * 1024
}

# 📁 Discos adicionales
locals {
  additional_disks_flat = flatten([
    for vm_name, vm in var.vm_definitions : (
      vm.additional_disks != null ? [
        for idx, disk in vm.additional_disks : {
          key  = "${vm_name}-${idx}"
          name = "${vm_name}-disk-${idx}"
          size = disk.size
          type = disk.type
          pool = libvirt_pool.volumetmp_flatcar_03.name
        }
      ] : []
    )
  ])
  additional_disks_map = { for disk in local.additional_disks_flat : disk.key => disk }
}

resource "libvirt_volume" "additional_disks" {
  for_each = local.additional_disks_map

  name   = each.value.name
  pool   = each.value.pool
  format = each.value.type
  size   = each.value.size * 1024 * 1024
}

# 🖥️ Definición de las máquinas virtuales
resource "libvirt_domain" "machine" {
  for_each = var.vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  arch    = "x86_64"
  machine = "pc-q35-rhel9.4.0"

  cpu {
    mode = "host-model"
  }

  network_interface {
    network_id     = libvirt_network.kube_network_03.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  dynamic "disk" {
    for_each = { for k, v in libvirt_volume.additional_disks : k => v if startswith(k, "${each.key}-") }
    content {
      volume_id = disk.value.id
    }
  }

  coreos_ignition = libvirt_ignition.ignition[each.key].id

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# 📤 Salida de direcciones IP
output "ip_addresses" {
  value = {
    for key, machine in libvirt_domain.machine :
    key => machine.network_interface[0].addresses[0] if length(machine.network_interface[0].addresses) > 0
  }
}
