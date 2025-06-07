#cloud-init network-config – plantilla
######################################
version: 2
renderer: NetworkManager        # <- explícito, es la opción recomendada en Alma Linux 9

ethernets:
  eth0:
    match:
      name: eth0                # garantiza que sólo se aplique a esta interfaz
    dhcp4: false
    dhcp6: false

    addresses:
      - ${ip}/24
    gateway4: ${gateway}

    nameservers:
      addresses:
        - ${dns1}
        - ${dns2}
      search:
        - ${cluster_domain}

    # ▸ Rutas estáticas persistentes ◂
    routes:
      - to: 10.17.3.0/24
        via: ${host_ip}
      - to: 10.17.4.0/24
        via: ${host_ip}
      - to: 10.17.5.0/24
        via: ${host_ip}