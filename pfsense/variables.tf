# pfsense\variables.tf
variable "pfsense_vm_name" {
  type = string
}

variable "pfsense_image" {
  type = string
}

variable "pfsense_pool_path" {
  type = string
}

variable "pfsense_vm_config" {
  type = object({
    cpus   = number
    memory = number
  })
}

variable "wan_ip" {
  type = string
}

variable "lan_ip" {
  type = string
}
