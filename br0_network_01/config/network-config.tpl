# br0_network_01\config\network-config.tpl
version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses:
      - ${ip}/24
    gateway4: ${gateway}
    nameservers:
      addresses:
        - ${dns1}
        - ${dns2}