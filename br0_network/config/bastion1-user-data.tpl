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
    content: c2VhcmNoIGNlZmFzbG9jYWxzZXJ2ZXIuY29tCm5hbWVzZXJ2ZXIgMTAuMTcuMy4xMQpuYW1lc2VydmVyIDguOC44Ljg=
    owner: root:root
    path: /etc/resolv.conf
    permissions: "0644"

  - path: /etc/systemd/network/10-static-en.network
    content: |
      [Match]
      Name=eth0

      [Network]
      Address=${ip}/24
      Gateway=${gateway}
      DNS=${dns1}
      DNS=${dns2}

  - path: /usr/local/bin/set-hosts.sh
    content: |
      #!/bin/bash
      echo "127.0.0.1   localhost" > /etc/hosts
      echo "::1         localhost" >> /etc/hosts
      echo "${ip}  ${hostname} ${short_hostname}" >> /etc/hosts
    permissions: "0755"

runcmd:
  - sudo ip route add 10.17.3.0/24 via 192.168.0.21 dev eth0
  - sudo ip route add 10.17.4.0/24 via 192.168.0.21 dev eth0
  - echo "Instance setup completed" >> /var/log/cloud-init-output.log
  - ["dnf", "install", "-y", "firewalld"]
  - ["systemctl", "enable", "--now", "firewalld"]
  - ["systemctl", "restart", "NetworkManager.service"]
  - /usr/local/bin/set-hosts.sh

timezone: ${timezone}
