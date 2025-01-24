# pfsense\variables.tf
variable "pfsense_image" {
  description = "Path to the pfSense ISO image"
  type        = string
}

variable "pfsense_pool_path" {
  description = "Path to the storage pool"
  type        = string
}

variable "pfsense_vm_config" {
  description = "Configuration for the pfSense virtual machine"
  type = object({
    cpus         = number
    memory       = number
    disk_size_gb = number
    wan_ip       = string
    lan_ip       = string
  })
}

variable "pfsense_vm_name" {
  type = string
}