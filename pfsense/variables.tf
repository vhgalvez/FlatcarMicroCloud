# pfsense\variables.tf
variable "pfsense_vm_name" {
  type    = string
  default = "pfsense" # Nombre predeterminado de la VM
}

variable "pfsense_image" {
  type    = string
  default = "/mnt/lv_data/organized_storage/images/pfsense_base.qcow2" # Ruta de la imagen base de pfSense
}

variable "pfsense_pool_path" {
  type    = string
  default = "/mnt/lv_data/organized_storage/volumes/pfsense" # Ruta para el almacenamiento de la VM
}

variable "pfsense_vm_config" {
  type = object({
    cpus         = number
    memory       = number
    disk_size_gb = number
  })
  default = {
    cpus         = 2    # CPUs asignadas a la VM
    memory       = 2048 # Memoria en MB
    disk_size_gb = 40   # Tamaño del disco en GB
  }
}

variable "wan_ip" {
  type    = string
  default = "192.168.0.200" # Dirección IP de la interfaz WAN
}

variable "lan_ip" {
  type    = string
  default = "192.168.1.1" # Dirección IP de la interfaz LAN
}
