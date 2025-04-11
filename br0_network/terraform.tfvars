# br0_network/terraform.tfvars

rocky9_image = "/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

vm_rockylinux_definitions = {
  k8s-api-lb = {
    cpus           = 1
    memory         = 512
    ip             = "10.17.5.20"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = 20 # Tamaño en GB (entero)
    volume_name    = "k8s-api-lb-volume"
    hostname       = "k8s-api-lb.cefaslocalserver.com"
    gateway        = "10.17.5.1"
    dns1           = "10.17.3.11"
    dns2           = "8.8.8.8"
    short_hostname = "k8s-api-lb"
  }
}

cluster_name        = "cluster_cefaslocalserver"
cluster_domain      = "cefaslocalserver.com"
rocky9_network_name = "br0"

ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]

timezone = "Europe/London"

