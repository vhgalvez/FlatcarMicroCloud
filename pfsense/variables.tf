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

variable "vlan_config" {
  type = map(object({
    vlan_tag   = number
    vlan_desc  = string
    dhcp_start = string
    dhcp_end   = string
    network    = string
    gateway    = string
  }))
  default = {
    dmz = {
      vlan_tag   = 20
      vlan_desc  = "DMZ VLAN"
      dhcp_start = "192.168.2.100"
      dhcp_end   = "192.168.2.200"
      network    = "192.168.2.0/24"
      gateway    = "192.168.2.1"
    }
    vpn = {
      vlan_tag   = 30
      vlan_desc  = "VPN VLAN"
      dhcp_start = "10.17.0.100"
      dhcp_end   = "10.17.0.200"
      network    = "10.17.0.0/24"
      gateway    = "10.17.0.1"
    }
  }
}
