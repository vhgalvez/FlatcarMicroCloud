# br0_network_01/terraform.tfvars
so_image = "/var/lib/libvirt/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2"

vm_linux_definitions = {
  k8s-api-lb = {
    cpus           = 1
    memory         = 512
    ip             = "192.168.0.30"
    volume_format  = "qcow2"
    volume_pool    = "default"
    volume_size    = 20 # Tamaño en GB (entero)
    volume_name    = "k8s-api-lb-volume"
    hostname       = "k8s-api-lb.socialdevs.site"
    gateway        = "192.168.0.1"
    dns1           = "10.17.3.11"
    dns2           = "8.8.8.8"
    short_hostname = "k8s-api-lb"    
  }
}

cluster_name    = "cluster_socialdevs"
cluster_domain  = "socialdevs.site"
so_network_name = "br0"
vm_role_name    = "k8s-api-lb"

host_ip         = "192.168.0.40"

ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdfUJjRAJuFcdO0J8CIOkjaKpqP6h9TqDRhZOJTac0199gFUvAJF9R/MAqwDLi2QI6OtYjz1CiCSVLtVQ2fTTIdwVibr+ZKDcbx/E7ivKUUbcmAOU8NP1gv3e3anoUd5k/0h0krP88CXosr41eTih4EcKhBAKbeZ11M0i9GZOux+/WweLtSQ3NU07sUkf1jDIoBungg77unmadqP3m9PUdkFP7tZ2lufcs3iq+vq8JaUBs/hZKNmWOXpnAyNxD9RlBJmvW2QgHmX53y3WC9bWUEUrwfDMB2wAqWPEDfj+5jsXQZcVE4pqD6T1cPaITnr9KFGnCCG1VQg31t1Jttg8z vhgalvez@gmail.com"
]

timezone = "Europe/Madrid"

# Verificación adicional:
# - Asegúrate de que la red "br0" esté configurada correctamente en el host.
# - Confirma que el archivo de imagen especificado en "so_image" existe y tiene los permisos adecuados.
# - Valida que las claves SSH sean correctas y funcionales.
