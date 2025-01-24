# pfsense\terraform.tfvars

pfsense_image     = "/mnt/lv_data/organized_storage/images/pfsense_base_optimized.qcow2"
pfsense_pool_path = "/mnt/lv_data/organized_storage/volumes/pfsense"

pfsense_vm_config = {
  cpus         = 2
  memory       = 2048
  disk_size_gb = 40
  wan_ip       = "192.168.0.200"
  lan_ip       = "192.168.1.1"
}


pfsense_vm_name = "pfsense_net"