#cloud-config
version: 2
renderer: NetworkManager
ethernets:
  eth0:
    dhcp4: false
    dhcp6: false
    addresses:
      - ${ip}/24
    gateway4: ${gateway}
    nameservers:
      search:
        - ${cluster_domain}
      addresses:
        - ${dns1}
        - ${dns2}
    routes:
      - to: 10.17.3.0/24
        via: ${host_ip}
      - to: 10.17.4.0/24
        via: ${host_ip}
      - to: 10.17.5.0/24
        via: ${host_ip}