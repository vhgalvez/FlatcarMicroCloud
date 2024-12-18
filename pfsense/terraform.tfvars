
# pfsense\terraform.tfvars
pfsense_image      = "/mnt/lv_data/organized_storage/images/netgate-installer-amd64.iso"
pfsense_pool_path  = "/mnt/lv_data/organized_storage/volumes/pfsense"
wan_subnet         = "192.168.100.0/24"
lan_subnet         = "192.168.1.0/24"

pfsense_vm_config = {
  cpus         = 2
  memory       = 2048
  disk_size_gb = 20
  wan_mac      = "52:54:00:11:22:33"
  lan_mac      = "52:54:00:44:55:66"
  wan_ip       = "192.168.100.1"
  lan_ip       = "192.168.1.1"
}

ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]

timezone = "Europe/London"
