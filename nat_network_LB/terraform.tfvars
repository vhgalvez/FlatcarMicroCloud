# nat_network_LB/terraform.tfvars

so_image = "/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

vm_linux_definitions = {
  "load_balancer1" = {
    cpus            = 1
    memory          = 512
    domain_memory   = 512
    ip              = "192.168.0.30"
    mac             = "52:54:00:aa:bb:cc"
    hostname        = "loadbalancer1.socialdevs.site"
    short_hostname  = "loadbalancer1"
    volume_name     = "loadbalancer1_volume"
    volume_format   = "qcow2"
    volume_size     = 30
    volume_pool     = "default"
    cloudinit_disk  = "loadbalancer1-seed.iso"
    cloudinit_pool  = "default"
    gateway         = "192.168.0.1"
    dns1            = "10.17.3.11"
    dns2            = "8.8.8.8"
  },
  "load_balancer2" = {
    cpus            = 1
    memory          = 512
    domain_memory   = 512
    ip              = "192.168.0.31"
    mac             = "52:54:00:39:ae:c8"
    hostname        = "loadbalancer2.socialdevs.site"
    short_hostname  = "loadbalancer2"
    volume_name     = "loadbalancer2_volume"
    volume_format   = "qcow2"
    volume_size     = 30
    volume_pool     = "default"
    cloudinit_disk  = "loadbalancer2-seed.iso"
    cloudinit_pool  = "default"
    gateway         = "192.168.0.1"
    dns1            = "10.17.3.11"
    dns2            = "8.8.8.8"
  }
}

# Variables globales
cluster_name    = "cluster_socialdevs"
cluster_domain  = "socialdevs.site"
so_network_name = "br0"
host_ip         = "192.168.0.40"
timezone        = "Europe/Madrid"

# Claves SSH permitidas en cloud-init
ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdfUJjRAJuFcdO0J8CIOkjaKpqP6h9TqDRhZOJTac0199gFUvAJF9R/MAqwDLi2QI6OtYjz1CiCSVLtVQ2fTTIdwVibr+ZKDcbx/E7ivKUUbcmAOU8NP1gv3e3anoUd5k/0h0krP88CXosr41eTih4EcKhBAKbeZ11M0i9GZOux+/WweLtSQ3NU07sUkf1jDIoBungg77unmadqP3m9PUdkFP7tZ2lufcs3iq+vq8JaUBs/hZKNmWOXpnAyNxD9RlBJmvW2QgHmX53y3WC9bWUEUrwfDMB2wAqWPEDfj+5jsXQZcVE4pqD6T1cPaITnr9KFGnCCG1VQg31t1Jttg8z vhgalvez@gmail.com"
]