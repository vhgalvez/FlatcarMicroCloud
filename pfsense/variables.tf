# pfsense\variables.tf

variable "pfsense_image" {
  description = "Ruta a la ISO de pfSense"
  type        = string
}

variable "pfsense_pool_path" {
  description = "Ruta para el almacenamiento de volúmenes de pfSense"
  type        = string
}

variable "pfsense_vm_config" {
  description = "Configuración de la máquina virtual de pfSense"
  type = object({
    cpus         = number
    memory       = number
    disk_size_gb = number
    wan_mac      = string
    lan_mac      = string
    wan_ip       = string
    lan_ip       = string
  })
}

variable "pfsense_boot_order" {
  description = "Orden de arranque para la VM de pfSense"
  type        = list(string)
  default     = ["cdrom", "hd"]
}
