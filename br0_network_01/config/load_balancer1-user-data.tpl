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
  - path: /etc/sysconfig/selinux
    permissions: "0644"
    content: |
      SELINUX=disabled
      SELINUXTYPE=targeted
  - path: /etc/resolv.conf
    permissions: "0644"
    content: |
      search socialdevs.site
      nameserver 10.17.3.11
      nameserver 8.8.8.8
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
  - fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
  - echo "/swapfile none swap sw 0 0" >> /etc/fstab
  - dnf install -y firewalld resolvconf chrony NetworkManager
  - systemctl enable --now firewalld chronyd NetworkManager
  - nmcli connection show --active | grep -E "eth0|System" | awk '{print $1}' | xargs -r -I {} nmcli connection down "{}" || true
  - nmcli connection show | grep -E "eth0|System" | awk '{print $1}' | xargs -r -I {} nmcli connection delete "{}" || true
  - rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
  - nmcli connection add type ethernet con-name eth0 ifname eth0 ipv4.method manual ipv4.addresses "${ip}/24" ipv4.gateway "${gateway}" ipv4.dns "${dns1},${dns2}" ipv4.dns-search "${cluster_domain}"
  - nmcli connection modify eth0 +ipv4.routes "10.17.3.0/24 ${host_ip}"
  - nmcli connection modify eth0 +ipv4.routes "10.17.4.0/24 ${host_ip}"
  - nmcli connection modify eth0 +ipv4.routes "10.17.5.0/24 ${host_ip}"
  - nmcli connection up eth0
  - firewall-cmd --permanent --add-port=443/tcp
  - firewall-cmd --permanent --add-port=6443/tcp
  - firewall-cmd --reload
  - /usr/local/bin/set-hosts.sh
  - sysctl --system

timezone: ${timezone}