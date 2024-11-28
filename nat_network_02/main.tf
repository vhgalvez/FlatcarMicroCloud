# nat_network_02\main.tf
terraform {
  required_version = "= 1.9.8"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
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

# Crear la red NAT
resource "libvirt_network" "kube_network_02" {
  name      = var.rocky9_network_name
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}

# Crear el pool de almacenamiento
resource "libvirt_pool" "volumetmp_nat_02" {
  name = "${var.cluster_name}_nat_02"
  type = "dir"

  target {
    path = "/mnt/lv_data/organized_storage/volumes/${var.cluster_name}_nat_02"
  }
}

# Crear el volumen base de la imagen
resource "libvirt_volume" "rocky9_image" {
  depends_on = [libvirt_pool.volumetmp_nat_02]

  name   = "${var.cluster_name}_rocky9_image"
  source = var.rocky9_image
  pool   = libvirt_pool.volumetmp_nat_02.name
  format = "qcow2"
}

# Crear disco adicional para storage1 (si aplica)
resource "libvirt_volume" "additional_disk_rc_storage1" {
  depends_on = [libvirt_pool.volumetmp_nat_02]

  name   = var.additional_disk_rc_storage1.name
  pool   = libvirt_pool.volumetmp_nat_02.name
  format = var.additional_disk_rc_storage1.format
  size   = var.additional_disk_rc_storage1.size
}

# Configurar los datos de Cloud-Init
data "template_file" "vm_configs" {
  for_each = var.vm_rockylinux_definitions

  template = file("${path.module}/config/${each.key}-user-data.tpl")
  vars = {
    ssh_keys       = jsonencode(var.ssh_keys),
    hostname       = each.value.hostname,
    short_hostname = each.value.short_hostname,
    timezone       = var.timezone,
    ip             = each.value.ip,
    gateway        = var.gateway,
    dns1           = var.dns1,
    dns2           = var.dns2
  }
}

# Crear disco de Cloud-Init
resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  for_each = var.vm_rockylinux_definitions

  name      = "${each.key}_cloudinit.iso"
  pool      = libvirt_pool.volumetmp_nat_02.name
  user_data = data.template_file.vm_configs[each.key].rendered
}

# Crear los discos de las máquinas virtuales
resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_rockylinux_definitions

  depends_on = [libvirt_volume.rocky9_image]

  name           = "${each.key}-${var.cluster_name}.qcow2"
  base_volume_id = libvirt_volume.rocky9_image.id
  pool           = libvirt_pool.volumetmp_nat_02.name
  format         = "qcow2"
  size           = max(each.value.volume_size * 1024 * 1024 * 1024, libvirt_volume.rocky9_image.size)
}

# Crear las máquinas virtuales
resource "libvirt_domain" "vm_nat_02" {
  for_each = var.vm_rockylinux_definitions

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.cpus

  network_interface {
    network_id     = libvirt_network.kube_network_02.id
    wait_for_lease = true
    addresses      = [each.value.ip]
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
    mode = "host-passthrough"
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
