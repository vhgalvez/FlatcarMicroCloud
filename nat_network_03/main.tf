terraform {
  required_version = "= 1.9.6"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.0"
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

resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
  dhcp {
    enabled = true
  }
}

resource "libvirt_pool" "volumetmp_flatcar_03" {
  name = "volumetmp_flatcar_03"
  type = "dir"
  path = "/mnt/lv_data/organized_storage/volumes/volumetmp_flatcar_03"
}

resource "libvirt_volume" "base" {
  name   = "base"
  source = var.base_image
  pool   = libvirt_pool.volumetmp_flatcar_03.name
  format = "qcow2"
}

data "template_file" "vm-configs" {
  for_each = var.vm_definitions

  template = file("${path.module}/configs/machine-${each.key}-config.yaml.tmpl")

  vars = {
    ssh_keys        = join(",", var.ssh_keys)
    node_name       = each.value.node_name
    ip              = each.value.ip
    host_name       = each.value.name_dominio
    gateway         = var.gateway
    dns1            = var.dns1
    dns2            = var.dns2
    initial_cluster = var.initial_cluster
  }
}

data "ct_config" "vm-ignitions" {
  for_each = var.vm_definitions
  content  = data.template_file.vm-configs[each.key].rendered
}

resource "local_file" "ignition_configs" {
  for_each = var.vm_definitions

  content  = data.ct_config.vm-ignitions[each.key].rendered
  filename = "${path.module}/ignition-configs/${each.key}.ign"
}

resource "libvirt_ignition" "ignition" {
  for_each = var.vm_definitions

  name    = "${each.key}-ignition"
  pool    = libvirt_pool.volumetmp_flatcar_03.name
  content = data.ct_config.vm-ignitions[each.key].rendered
}

resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_definitions

  name           = "${each.key}-disk"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp_flatcar_03.name
  format         = "qcow2"
  size           = each.value.disk_size * 1024 * 1024 # size in MB converted to bytes
}

resource "libvirt_domain" "machine" {
  for_each = var.vm_definitions

  name   = each.key
  vcpu   = each.value.cpus
  memory = each.value.memory

  network_interface {
    network_id     = libvirt_network.kube_network_03.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
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

output "ip_addresses" {
  value = { for key, machine in libvirt_domain.machine : key => machine.network_interface[0].addresses[0] if length(machine.network_interface[0].addresses) > 0 }
}