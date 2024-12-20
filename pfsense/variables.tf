# pfsense\variables.tf
variable "pfsense_image" {
  type    = string
  default = "/mnt/lv_data/organized_storage/images/pfSense-Base.qcow2"
}

variable "pfsense_pool_path" {
  type    = string
  default = "/mnt/lv_data/organized_storage/volumes/pfsense"
}

variable "pfsense_vm_config" {
  type = object({
    cpus         = number
    memory       = number
    disk_size_gb = number
  })
  default = {
    cpus         = 2
    memory       = 2048
    disk_size_gb = 40
  }
}

variable "wan_ip" {
  type    = string
  default = "192.168.0.200"
}

variable "lan_ip" {
  type    = string
  default = "192.168.1.1"
}