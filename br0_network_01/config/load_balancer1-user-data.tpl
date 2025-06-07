#cloud-config
hostname: ${hostname}
manage_etc_hosts: false

growpart:
  mode: auto
  devices: ["/"]

resize_rootfs: true

chpasswd:
  list: |
    core:$6$hNh1nwO5OWWct4aZ$OoeAkQ4gKNBnGYK0ECi8saBMbUNeQRMICcOPYEu1bFuj9Axt4Rh6EnGba07xtIsGNt2wP9SsPlz543gfJww11/
    root:$6$hNh1nwO5OWWct4aZ$OoeAkQ4gKNBnGYK0ECi8saBMbUNeQRMICcOPYEu1bFuj9Axt4Rh6EnGba07xtIsGNt2wP9SsPlz543gfJww11/
  expire: false

ssh_pwauth: true
disable_root: false

users:
  - default
  - name: core
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: [adm, wheel]
    lock_passwd: false
    ssh_authorized_keys: ${ssh_keys}

write_files:
  # SELinux en modo disabled
  - path: /etc/sysconfig/selinux
    permissions: "0644"
    owner: root:root
    content: |
      SELINUX=disabled
      SELINUXTYPE=targeted

  # /etc/resolv.conf inicial
  - path: /etc/resolv.conf
    permissions: "0644"
    owner: root:root
    content: |
      search ${cluster_domain}
      nameserver ${dns1}
      nameserver ${dns2}

  # Conexión estática para eth0
  - path: /etc/NetworkManager/system-connections/eth0.nmconnection
    owner: root:root
    permissions: "0600"
    content: |
      [connection]
      id=eth0
      uuid=3b8df4d8-3d8b-4f15-9a22-df9cc0a509b3
      type=ethernet
      interface-name=eth0
      autoconnect=true
      autoconnect-priority=100

      [ipv4]
      method=manual
      addresses1=${ip}/24,${gateway}
      dns=${dns1};${dns2};
      dns-search=${cluster_domain}
      route-metric=10
      ignore-auto-routes=true          # evita que DHCP añada rutas
      ignore-auto-dns=true             # evita que DHCP cambie resolv.conf
      never-default=false

      # Rutas estáticas persistentes (formato correcto)
      routes1=10.17.3.0/24,${host_ip}
      routes2=10.17.4.0/24,${host_ip}
      routes3=10.17.5.0/24,${host_ip}

      [ipv6]
      method=ignore

  # Script para /etc/hosts
  - path: /usr/local/bin/set-hosts.sh
    permissions: "0755"
    content: |
      #!/bin/bash
      echo "127.0.0.1   localhost"       >  /etc/hosts
      echo "::1         localhost"       >> /etc/hosts
      echo "${ip}  ${hostname} ${short_hostname}" >> /etc/hosts

  # sysctl
  - path: /etc/sysctl.d/99-haproxy-nonlocal-bind.conf
    permissions: "0644"
    content: |
      net.ipv4.ip_forward = 1
      net.ipv4.ip_nonlocal_bind = 1

  # chrony
  - path: /etc/chrony.conf
    permissions: "0644"
    content: |
      server 10.17.3.11 iburst prefer
      server 0.pool.ntp.org iburst
      server 1.pool.ntp.org iburst
      server 2.pool.ntp.org iburst
      allow 10.17.0.0/16

runcmd:
  - echo "▶ cloud-init: inicio" >> /var/log/cloud-init-output.log

  # swap de 2 GiB
  - fallocate -l 2G /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo "/swapfile none swap sw 0 0" >> /etc/fstab

  # Instalar y habilitar servicios base
  - dnf install -y firewalld resolvconf chrony NetworkManager
  - systemctl enable --now firewalld chronyd NetworkManager

  # Abrir puertos (ejemplo)
  - firewall-cmd --permanent --add-port=443/tcp
  - firewall-cmd --permanent --add-port=80/tcp
  - firewall-cmd --permanent --add-port=6443/tcp
  - firewall-cmd --reload

  # Aplicar /etc/hosts
  - /usr/local/bin/set-hosts.sh

  # Recargar sysctl
  - sysctl --system

  # Forzar NetworkManager a recargar la conexión keyfile
  - nmcli connection reload
  - nmcli connection down "Wired connection 1" || true   # si existe
  - nmcli connection delete "Wired connection 1" || true
  - nmcli connection up eth0

  - echo "▶ cloud-init: finalizado" >> /var/log/cloud-init-output.log

timezone: ${timezone}
