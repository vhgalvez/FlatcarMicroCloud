# br0_network\variables.tf

variable "ssh_keys" {
  description = "SSH keys for the VMs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "cluster_domain" {
  description = "Domain of the cluster"
  type        = string
}

variable "rocky9_image" {
  description = "Path to the Rocky Linux 9 image"
  type        = string
}

variable "rocky9_network_name" {
  description = "The network name for the VMs"
  type        = string
}

variable "timezone" {
  description = "Timezone for the infrastructure"
  type        = string
  default     = "Europe/London"
}

variable "vm_rockylinux_definitions" {
  description = "Definitions of virtual machines including CPU and memory configuration"
  type = map(object({
    cpus           = number
    memory         = number
    ip             = string
    volume_format  = string
    volume_pool    = string
    volume_size    = string
    volume_name    = string
    hostname       = string
    gateway        = string
    dns1           = string
    dns2           = string
    short_hostname = string
  }))
}
