# nat_network_02\variables.tf
variable "ssh_keys" {
  description = "SSH keys for the VMs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "so_image" {
  description = "Path to the Rocky Linux 9 image"
  type        = string
}

variable "so_network_name" {
  description = "The network name for the VMs"
  type        = string
}

variable "timezone" {
  description = "Timezone for the infrastructure"
  type        = string
  default     = "Europe/Madrid"
}

variable "gateway" {
  description = "Gateway for the VMs"
  type        = string
}

variable "dns1" {
  description = "Primary DNS server"
  type        = string
}

variable "dns2" {
  description = "Secondary DNS server"
  type        = string
}

variable "cluster_domain" {
  description = "Domain of the cluster"
  type        = string
}

variable "vm_linux_definitions" {
  description = "Definitions of virtual machines including CPU and memory configuration"
  type = map(object({
    cpus           = number
    memory         = number
    ip             = string
    cloudinit_disk = string
    cloudinit_pool = string
    domain_memory  = string
    volume_format  = string
    volume_pool    = string
    volume_size    = string
    volume_name    = string
    hostname       = string
    short_hostname = string
  }))
}

variable "additional_disks" {
  description = "Map of additional disks for each VM"
  type        = map(object({
    size = number
    type = string
  }))
  default = {}
}
