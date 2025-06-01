# br0_network_01\variables.tf

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

variable "so_image" {
  description = "Path to the base Linux image"
  type        = string
}

variable "so_network_name" {
  description = "The network name for the VMs"
  type        = string
}

variable "timezone" {
  description = "Timezone for the infrastructure"
  type        = string
  default     = "Europe/madrid"
}

variable "vm_role_name" {
  description = "Name of the VM role (used for dynamic resource naming)"
  type        = string
}


variable "vm_linux_definitions" {
  description = "Configuration map for each Linux VM to be provisioned"
  type = map(object({
    cpus           = number
    memory         = number
    ip             = string
    volume_format  = string
    volume_pool    = string
    volume_size    = number
    volume_name    = string
    hostname       = string
    gateway        = string
    dns1           = string
    dns2           = string
    short_hostname = string
  }))
}
