# br0_network/terraform.tfvars

rocky9_image = "/mnt/lv_data/organized_storage/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

vm_rockylinux_definitions = {
  bastion1 = {
    cpus           = 2
    memory         = 1024
    ip             = "192.168.0.200"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = 20 # Tamaño en GB (entero)
    volume_name    = "bastion1-volume"
    hostname       = "bastion1.cefaslocalserver.com"
    gateway        = "192.168.0.1"
    dns1           = "8.8.8.8"
    dns2           = "8.8.4.4"
    short_hostname = "bastion"
  }
}

cluster_name        = "cluster_cefaslocalserver"
cluster_domain      = "cefaslocalserver.com"
rocky9_network_name = "br0"

ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]

timezone = "Europe/London"
