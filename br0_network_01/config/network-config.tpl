version: 2
renderer: NetworkManager
ethernets:
  eth0:
    match:
      name: eth0
    dhcp4: false
    dhcp6: false
    addresses:
      - 192.168.0.30/24
    gateway4: 192.168.0.1
    nameservers:
      addresses:
        - 1.1.1.1
        - 8.8.8.8
      search:
        - mycluster.local
    routes:
      - to: 10.17.3.0/24
        via: 192.168.0.40
      - to: 10.17.4.0/24
        via: 192.168.0.40
      - to: 10.17.5.0/24
        via: 192.168.0.40