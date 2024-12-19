# pfsense\outputs.tf
output "pfsense_vm_name" {
  value = libvirt_domain.pfsense.name
}

output "pfsense_vnc_connection" {
  value = "VNC connection details: Connect to localhost on the assigned port."
}
