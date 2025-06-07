#cloud-config
hostname: ${hostname}
manage_etc_hosts: false

users:
  - default
  - name: core
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
    groups: [wheel, adm]
    lock_passwd: false
    ssh_authorized_keys: ${ssh_keys}

disable_root: false
ssh_pwauth: true

network:
  version: 2
  renderer: NetworkManager
  ethernets:
    eth0:
      match:
        name: eth0
      dhcp4: false
      dhcp6: false
      addresses: [ "${ip}/24" ]
      gateway4: ${gateway}
      nameservers:
        search: [ "${cluster_domain}" ]
        addresses: [ "${dns1}", "${dns2}" ]
      routes:
        - to: 10.17.3.0/24
          via: ${host_ip}
        - to: 10.17.4.0/24
          via: ${host_ip}
        - to: 10.17.5.0/24
          via: ${host_ip}

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
      net.ipv4.ip_forward = 1
      net.ipv4.ip_nonlocal_bind = 1

  - path: /etc/chrony.conf
    permissions: "0644"
    content: |
      server 10.17.3.11 iburst prefer
      server 0.pool.ntp.org iburst
      server 1.pool.ntp.org iburst
      server 2.pool.ntp.org iburst
      allow 10.17.0.0/16

runcmd:
  - fallocate -l 2G /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo "/swapfile none swap sw 0 0" >> /etc/fstab
  - dnf install -y firewalld resolvconf chrony NetworkManager
  - systemctl enable --now firewalld chronyd NetworkManager
  - firewall-cmd --permanent --add-port=443/tcp
  - firewall-cmd --permanent --add-port=6443/tcp
  - firewall-cmd --reload
  - /usr/local/bin/set-hosts.sh
  - sysctl --system

timezone: ${timezone}