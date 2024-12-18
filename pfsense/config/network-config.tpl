version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses:
      - ${pfsense_vm_config.wan_ip}/24
    gateway4: ${pfsense_vm_config.gateway}
    nameservers:
      addresses: ${pfsense_vm_config.dns}
  eth1:
    dhcp4: false
    addresses:
      - ${pfsense_vm_config.lan_ip}/24