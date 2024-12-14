variable "ssh_keys" {
  description = "SSH keys for the VMs"
  type        = list(string)
}

variable "timezone" {
  description = "Timezone for the infrastructure"
  type        = string
  default     = "Europe/London"
}

variable "pfsense_image" {
  description = "Path to the pfSense ISO"
  type        = string
}

variable "pfsense_pool_path" {
  description = "Path to store pfSense VM volumes"
  type        = string
}

variable "wan_subnet" {
  description = "Subnet for the WAN network"
  type        = string
  default     = "192.168.100.0/24"
}

variable "lan_subnet" {
  description = "Subnet for the LAN network"
  type        = string
  default     = "192.168.1.0/24"
}

variable "pfsense_vm_config" {
  description = "Configuration of the pfSense VM"
  type = object({
    cpus          = number
    memory        = number
    disk_size_gb  = number
    wan_mac       = string
    lan_mac       = string
    wan_ip        = string
    lan_ip        = string
  })
}