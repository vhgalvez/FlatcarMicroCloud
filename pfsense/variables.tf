# pfsense\variables.tf

# Variables para la configuración de pfSense

# Claves SSH para acceder a las máquinas virtuales
variable "ssh_keys" {
  description = "SSH keys for the VMs"
  type        = list(string)
}

# Zona horaria de la infraestructura
variable "timezone" {
  description = "Timezone for the infrastructure"
  type        = string
  default     = "Europe/London"
}

# Ruta de la ISO de pfSense
variable "pfsense_image" {
  description = "Path to the pfSense ISO file"
  type        = string
}

# Ruta del pool de almacenamiento para volúmenes de pfSense
variable "pfsense_pool_path" {
  description = "Path to store pfSense VM volumes"
  type        = string
}

# Configuración de la red WAN (br0)
variable "wan_subnet" {
  description = "Subnet for the WAN network"
  type        = string
}

# Configuración de la red LAN (br1)
variable "lan_subnet" {
  description = "Subnet for the LAN network"
  type        = string
}

# Configuración principal de la máquina virtual de pfSense
variable "pfsense_vm_config" {
  description = "Configuration of the pfSense VM"
  type = object({
    cpus         = number      # Número de CPUs asignadas
    memory       = number      # Memoria asignada en MB
    disk_size_gb = number      # Tamaño del disco en GB
    wan_mac      = string      # Dirección MAC de la interfaz WAN
    lan_mac      = string      # Dirección MAC de la interfaz LAN
    wan_ip       = string      # Dirección IP para la interfaz WAN
    lan_ip       = string      # Dirección IP para la interfaz LAN
  })
}
