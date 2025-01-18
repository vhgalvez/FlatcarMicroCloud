# pfsense\outputs.tf
output "wan_ip" {
  description = "WAN IP for pfSense"
  value       = var.pfsense_vm_config.wan_ip
}

output "lan_ip" {
  description = "LAN IP for pfSense"
  value       = var.pfsense_vm_config.lan_ip
}

output "vnc_access" {
  description = "VNC Access for pfSense"
  value       = "Conéctate a la VM mediante VNC en el puerto asignado automáticamente."
}
