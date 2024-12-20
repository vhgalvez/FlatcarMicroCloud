# pfsense\main.tf
terraform {
  required_version = "= 1.10.1"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.1"
    }
    pfsense = {
      source  = "marshallford/pfsense"
      version = "0.7.2"
    }
  }
}

# Proveedor libvirt
provider "libvirt" {
  uri = "qemu:///system"
}

# Proveedor pfSense
provider "pfsense" {
  url      = "https://${var.wan_ip}" # Dirección IP inicial de WAN
  username = "admin"
  password = "pfsense"
  insecure = true
}

# Crear VLANs
resource "pfsense_vlan" "dmz_vlan" {
  interface = "lan"
  vlan_tag  = 20
  vlan_desc = "DMZ VLAN"
}

resource "pfsense_vlan" "vpn_vlan" {
  interface = "lan"
  vlan_tag  = 30
  vlan_desc = "VPN VLAN"
}

# Configurar DHCP para cada VLAN
resource "pfsense_dhcp_range" "dmz_dhcp" {
  interface = "dmz_vlan"
  range {
    start = "192.168.2.100"
    end   = "192.168.2.200"
  }
  domain = "dmz.local"
  dns    = ["192.168.2.1"]
}

resource "pfsense_dhcp_range" "vpn_dhcp" {
  interface = "vpn_vlan"
  range {
    start = "10.17.0.100"
    end   = "10.17.0.200"
  }
  domain = "vpn.local"
  dns    = ["10.17.0.1"]
}

# Configurar reglas de firewall
resource "pfsense_firewall_rule" "allow_http_dmz" {
  interface = "dmz_vlan"
  protocol  = "tcp"
  source {
    network = "192.168.2.0/24"
  }
  destination {
    port = "80"
  }
  action      = "pass"
  description = "Allow HTTP traffic in DMZ VLAN"
}

resource "pfsense_firewall_rule" "allow_vpn_to_lan" {
  interface = "vpn_vlan"
  protocol  = "tcp"
  source {
    network = "10.17.0.0/24"
  }
  destination {
    network = "192.168.1.0/24"
  }
  action      = "pass"
  description = "Allow VPN clients to access LAN"
}

# Configurar VPN WireGuard
resource "pfsense_wireguard" "vpn" {
  interface   = "wg0"
  address     = "10.17.0.1/24"
  port        = 51820
  private_key = "your_private_key_here"

  peer {
    public_key  = "peer_public_key_here"
    allowed_ips = "10.17.0.100/32"
    endpoint    = "peer_endpoint_here:51820"
  }
}
