#cloud-config
hostname: pfsense
manage_etc_hosts: true

users:
  - name: root
    lock_passwd: false
    plain_text_passwd: "$6$hNh1nwO5OWWct4aZ$OoeAkQ4gKNBnGYK0ECi8saBMbUNeQRMICcOPYEu1bFuj9Axt4Rh6EnGba07xtIsGNt2wP9SsPlz543gfJww11/"
    ssh_authorized_keys: ${ssh_keys}
    shell: /bin/bash

  - name: core
    lock_passwd: false
    plain_text_passwd: "$6$hNh1nwO5OWWct4aZ$OoeAkQ4gKNBnGYK0ECi8saBMbUNeQRMICcOPYEu1bFuj9Axt4Rh6EnGba07xtIsGNt2wP9SsPlz543gfJww11/"
    ssh_authorized_keys: ${ssh_keys}
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: ["wheel", "adm"]

chpasswd:
  expire: false

ssh_pwauth: true

write_files:
  - path: /etc/sysctl.conf
    content: |
      net.ipv4.ip_forward = 1

runcmd:
  - sysctl -p
  - echo "Instance setup completed" >> /var/log/cloud-init-output.log