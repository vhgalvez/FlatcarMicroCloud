# nat_network_LB\variables.tf
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

variable "cluster_domain" {
  description = "Domain of the cluster"
  type        = string
}

variable "host_ip" {
  description = "IP del gateway para enrutar hacia redes 10.17.3.0/24, 10.17.4.0/24 y 10.17.5.0/24"
  type        = string
}

variable "vm_linux_definitions" {
  description = "Definitions of virtual machines including CPU and memory configuration"
  type = map(object({
    cpus           = number
    memory         = number
    ip             = string
    mac            = string
    gateway        = string
    dns1           = string
    dns2           = string
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
  type = map(object({
    size = number
    type = string
  }))
  default = {}
}
