# variable.tf
variable "base_image" {
  description = "Path to the base VM image"
  type        = string
}

variable "vm_definitions" {
  description = "Definitions of virtual machines including CPU, memory, IP, domain name, and disk size"
  type = map(object({
    cpus         = number
    memory       = number
    ip           = string
    name_dominio = string
    disk_size    = number # in MB
    node_name    = string # node name
  }))
}

variable "ssh_keys" {
  description = "List of SSH keys to inject into VMs"
  type        = list(string)
}

variable "gateway" {
  description = "Gateway IP address"
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
variable "initial_cluster" {
  description = "The initial cluster configuration"
  type        = string

}
variable "node_name" {
  description = "Nombre del nodo"
  type        = string
  default     = null
}