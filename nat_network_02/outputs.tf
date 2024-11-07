# output.tf

output "ip_addresses" {
  value = { for key, machine in libvirt_domain.vm_nat_02 : key => var.vm_rockylinux_definitions[key].ip }
}
