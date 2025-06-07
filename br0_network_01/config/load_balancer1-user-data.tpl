#cloud-config
############################
# 1. HOSTNAME & USUARIOS   #
############################
hostname: ${hostname}
manage_etc_hosts: false

users:
  - default
  - name: core
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    groups: [wheel, adm]
    ssh_authorized_keys: ${ssh_keys}

disable_root: false
ssh_pwauth: true

############################
# 2. NETWORK (versión 2)   #
############################
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      match:
        name: eth0
      dhcp4: false
      dhcp6: false

      # IP fija
      addresses: [ "${ip}/24" ]
      gateway4:  ${gateway}

      nameservers:
        search: [ "${cluster_domain}" ]
        addresses: [ "${dns1}", "${dns2}" ]

      # Rutas estáticas persistentes
      routes:
        - to: 10.17.3.0/24
          via: ${host_ip}
        - to: 10.17.4.0/24
          via: ${host_ip}
        - to: 10.17.5.0/24
          via: ${host_ip}

############################
# 3. FICHEROS Y AJUSTES    #
############################
write_files:
  - path: /usr/local/bin/set-hosts.sh
    permissions: "0755"
    content: |
      #!/bin/bash
      echo "127.0.0.1   localhost" > /etc/hosts
      echo "::1         localhost" >> /etc/hosts
      echo "${ip}  ${hostname} ${short_hostname}" >> /etc/hosts

  - path: /etc/sysctl.d/99-custom.conf
    permissions: "0644"
    content: |
      net.ipv4.ip_forward       = 1
      net.ipv4.ip_nonlocal_bind = 1

  - path: /etc/chrony.conf
    permissions: "0644"
    content: |
      server 10.17.3.11 iburst prefer
      server 0.pool.ntp.org iburst
      server 1.pool.ntp.org iburst
      server 2.pool.ntp.org iburst
      allow 10.17.0.0/16

############################
# 4. COMANDOS DE ARRANQUE  #
############################
runcmd:
  - echo "▶ cloud-init start" >> /var/log/cloud-init-output.log

  # Swap de 2 GiB
  - fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
  - echo "/swapfile none swap sw 0 0" >> /etc/fstab

  # Paquetes básicos
  - dnf install -y firewalld resolvconf chrony
  - systemctl enable --now firewalld chronyd

  # Reglas de cortafuegos (ejemplo)
  - firewall-cmd --permanent --add-port=443/tcp
  - firewall-cmd --permanent --add-port=6443/tcp
  - firewall-cmd --reload

  # /etc/hosts y sysctl
  - /usr/local/bin/set-hosts.sh
  - sysctl --system

  - echo "▶ cloud-init done" >> /var/log/cloud-init-output.log

############################
# 5. VARIOS                #
############################
timezone: ${timezone}