# pfsense\outputs.tf
output "wan_ip" {
  description = "Dirección IP WAN de pfSense"
  value       = var.pfsense_vm_config.wan_ip
}

output "lan_ip" {
  description = "Dirección IP LAN de pfSense"
  value       = var.pfsense_vm_config.lan_ip
}

output "vnc_access" {
  description = "Acceso VNC para pfSense"
  value       = "Conéctate a la VM mediante VNC en la dirección configurada."
}
