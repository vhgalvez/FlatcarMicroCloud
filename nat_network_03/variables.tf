# nat_network_03\variables.tf
variable "base_image" {
  description = "Path to the base VM image"
  type        = string
}

variable "vm_definitions" {
  description = "Definitions of virtual machines"
  type = map(object({
    cpus             = number
    memory           = number
    ip               = string
    name_dominio     = string
    disk_size        = number
    node_name        = string
    additional_disks = optional(list(object({
      size = number
      type = string
    })))
  }))
}

variable "ssh_keys" {
  type        = list(string)
  description = "SSH keys"
}

variable "gateway" {
  type = string
}

variable "dns1" {
  type = string
}

variable "dns2" {
  type = string
}

variable "node_name" {
  type    = string
  default = null
}

variable "timezone" {
  type = string
}
