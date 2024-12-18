
# pfsense\terraform.tfvars


pfsense_image     = "/mnt/lv_data/organized_storage/images/netgate-installer-amd64.iso"
pfsense_pool_path = "/mnt/lv_data/organized_storage/volumes/pfsense"

pfsense_vm_config = {
  cpus         = 2
  memory       = 2048
  disk_size_gb = 20
  wan_mac      = "52:54:00:11:22:33"
  lan_mac      = "52:54:00:44:55:66"
}