
# br0_network\terraform.tfvars

rocky9_image = "/mnt/lv_data/organized_storage/images/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"

vm_rockylinux_definitions = {
  "bastion1" = {
    cpus           = 2,
    memory         = 2048,
    volume_name    = "bastion1_volume",
    volume_format  = "qcow2",
    volume_pool    = "default",
    volume_size    = "32212254720", # 30GB
    hostname       = "bastion1.cefaslocalserver.com",
    ip             = "192.168.0.20",
    gateway        = "192.168.0.1",
    dns1           = "10.17.3.11",
    dns2           = "8.8.8.8"
    short_hostname = "bastion1"
  }
}

cluster_name        = "cluster_cefaslocalserver"
cluster_domain      = "cefas-core.com"
rocky9_network_name = "br0"
ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]
timezone = "Europe/London"
