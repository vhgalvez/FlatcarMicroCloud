#cloud-config
hostname: ${hostname}
manage_etc_hosts: false

growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false

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
  - name: root
    ssh_authorized_keys: ${ssh_keys}

write_files:
  - encoding: b64
    content: U0VMSU5VWD1kaXNhYmxlZApTRUxJTlVYVFlQRT10YXJnZXRlZCAKIyAK
    owner: root:root
    path: /etc/sysconfig/selinux
    permissions: "0644"

  - encoding: b64
    content: c2VhcmNoIGNlZmFzbG9jYWxzZXJ2ZXIuY29tCm5hbWVzZXIgMTAuMTcuMy4xMQpuYW1lc2VydmVyIDguOC44Ljg=
    owner: root:root
    path: /etc/resolv.conf
    permissions: "0644"

  - path: /etc/NetworkManager/system-connections/eth0.nmconnection
    permissions: "0600"
    content: |
      [connection]
      id=eth0
      type=ethernet
      interface-name=eth0
      autoconnect=true

      [ipv4]
      method=manual
      addresses1=${ip}/24,${gateway}
      dns=${dns1};${dns2};
      dns-search=${cluster_domain}
      may-fail=false
      route-metric=10

      [ipv6]
      method=ignore

  - path: /usr/local/bin/set-hosts.sh
    content: |
      #!/bin/bash
      echo "127.0.0.1   localhost" > /etc/hosts
      echo "::1         localhost" >> /etc/hosts
      echo "${ip}  ${hostname} ${short_hostname}" >> /etc/hosts
    permissions: "0755"

  - path: /etc/sysctl.conf
    content: |
      net.ipv4.ip_forward = 1

  - path: /etc/NetworkManager/conf.d/dns.conf
    content: |
      [main]
      dns=none

  - path: /etc/chrony.conf
    permissions: "0644"
    content: |
      server 10.17.3.11 iburst prefer
      server 0.pool.ntp.org iburst
      server 1.pool.ntp.org iburst
      server 2.pool.ntp.org iburst
      allow 10.17.0.0/16

runcmd:
  - echo " Iniciando cloud-init en $(hostname)" >> /var/log/cloud-init-output.log
  - fallocate -l 2G /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo "/swapfile none swap sw 0 0" >> /etc/fstab
  - echo " Swap configurado" >> /var/log/cloud-init-output.log
  - dnf install -y firewalld resolvconf chrony
  - systemctl enable --now chronyd
  - firewall-cmd --permanent --add-port=443/tcp
  - firewall-cmd --permanent --add-port=123/tcp
  - firewall-cmd --permanent --add-port=80/tcp
  - firewall-cmd --permanent --add-port=6443/tcp
  - firewall-cmd --reload
  - echo " Firewall y NTP configurados" >> /var/log/cloud-init-output.log
  - /usr/local/bin/set-hosts.sh
  - sysctl -p
  - echo "nameserver ${dns1}" > /etc/resolvconf/resolv.conf.d/base
  - echo "nameserver ${dns2}" >> /etc/resolvconf/resolv.conf.d/base
  - echo "search ${cluster_domain}" >> /etc/resolvconf/resolv.conf.d/base
  - resolvconf -u
  - nmcli connection reload
  - echo " Configurando rutas estáticas en eth0..." >> /var/log/cloud-init-output.log
  - nmcli connection modify eth0 +ipv4.routes "10.17.4.0/24 ${gateway}"
  - nmcli connection modify eth0 +ipv4.routes "10.17.5.0/24 ${gateway}"
  - nmcli connection modify eth0 +ipv4.routes "10.17.3.0/24 ${gateway}"
  - nmcli connection down eth0 || true
  - nmcli connection up eth0
  - echo " Rutas estáticas aplicadas" >> /var/log/cloud-init-output.log
  - nmcli con delete "$(nmcli -t -f NAME con show --active | grep Wired)" || true
  - echo " cloud-init finalizado correctamente" >> /var/log/cloud-init-output.log

timezone: ${timezone}