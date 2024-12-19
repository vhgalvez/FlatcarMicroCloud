# pfsense\terraform.tfvars
pfsense_image     = "/mnt/lv_data/organized_storage/images/pfSense-Base.qcow2"
pfsense_pool_path = "/mnt/lv_data/organized_storage/volumes/pfsense"

pfsense_vm_config = {
  cpus         = 2
  memory       = 2048
  disk_size_gb = 40
}

wan_ip          = "192.168.0.200"  # Dirección IP para la interfaz WAN
lan_ip          = "192.168.1.1"    # Dirección IP para la interfaz LAN
