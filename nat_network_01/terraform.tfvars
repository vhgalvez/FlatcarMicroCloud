# kube_network_01/terraform.tfvars

rocky9_image = "/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

vm_rockylinux_definitions = {
  k8s-api-lb = {
    cpus           = 1
    memory         = 512
    ip             = "10.17.5.20"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = 20 # Tamaño en GB (entero)
    volume_name    = "k8s-api-lb-volume"
    hostname       = "k8s-api-lb.cefaslocalserver.com"
    gateway        = "110.17.5.1"
    dns1           = "10.17.3.11"
    dns2           = "8.8.8.8"
    short_hostname = "k8s-api-lb"
  }
}

cluster_name        = "cluster_cefaslocalserver"
cluster_domain      = "cefaslocalserver.com"
rocky9_network_name = "kube_network_01"

ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdfUJjRAJuFcdO0J8CIOkjaKpqP6h9TqDRhZOJTac0199gFUvAJF9R/MAqwDLi2QI6OtYjz1CiCSVLtVQ2fTTIdwVibr+ZKDcbx/E7ivKUUbcmAOU8NP1gv3e3anoUd5k/0h0krP88CXosr41eTih4EcKhBAKbeZ11M0i9GZOux+/WweLtSQ3NU07sUkf1jDIoBungg77unmadqP3m9PUdkFP7tZ2lufcs3iq+vq8JaUBs/hZKNmWOXpnAyNxD9RlBJmvW2QgHmX53y3WC9bWUEUrwfDMB2wAqWPEDfj+5jsXQZcVE4pqD6T1cPaITnr9KFGnCCG1VQg31t1Jttg8z vhgalvez@gmail.com"
]

timezone = "Europe/London"
