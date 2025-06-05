# nat_network_02\terraform.tfvars

# 📦 Imagen base del sistema operativo
so_image = "/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

# 🖥️ Definición de las VMs
vm_linux_definitions = {
  "infra-cluster" = {
    cpus           = 1
    memory         = 512
    ip             = "10.17.3.11"
    hostname       = "infra-cluster.socialdevs.site"
    short_hostname = "infra-cluster"
    volume_name    = "infra-cluster_volume"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = "32212254720" # 32 GB
    domain_memory  = "512"
    cloudinit_disk = "AlmaLinux-9_cloudinit_disk.iso"
    cloudinit_pool = "default"
  },
  "postgresql1" = {
    cpus           = 2
    memory         = 1024
    ip             = "10.17.3.14"
    hostname       = "postgresql1.socialdevs.site"
    short_hostname = "postgresql1"
    volume_name    = "postgresql1_volume"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = "32212254720" # 32 GB
    domain_memory  = "1024"
    cloudinit_disk = "AlmaLinux-9_cloudinit_disk.iso"
    cloudinit_pool = "default"
  }
}

# 🌐 Red y DNS
cluster_name    = "cluster_socialdevs"
cluster_domain  = "socialdevs.site"
so_network_name = "kube_network_02"
gateway         = "10.17.3.1"
dns1            = "10.17.3.11"
dns2            = "8.8.8.8"

# 🔐 Claves SSH autorizadas
ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdfUJjRAJuFcdO0J8CIOkjaKpqP6h9TqDRhZOJTac0199gFUvAJF9R/MAqwDLi2QI6OtYjz1CiCSVLtVQ2fTTIdwVibr+ZKDcbx/E7ivKUUbcmAOU8NP1gv3e3anoUd5k/0h0krP88CXosr41eTih4EcKhBAKbeZ11M0i9GZOux+/WweLtSQ3NU07sUkf1jDIoBungg77unmadqP3m9PUdkFP7tZ2lufcs3iq+vq8JaUBs/hZKNmWOXpnAyNxD9RlBJmvW2QgHmX53y3WC9bWUEUrwfDMB2wAqWPEDfj+5jsXQZcVE4pqD6T1cPaITnr9KFGnCCG1VQg31t1Jttg8z vhgalvez@gmail.com"
]

# 🕒 Zona horaria
timezone = "Europe/Madrid"
