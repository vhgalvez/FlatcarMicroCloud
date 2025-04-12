# nat_network_03\terraform.tfvars
base_image = "/var/lib/libvirt/images/flatcar_production_qemu_image.img"

vm_definitions = {
  # Master Nodes (optimizados: 2 vCPU y 2 GB RAM)
  master1 = {
    cpus         = 2
    memory       = 2048
    ip           = "10.17.4.21"
    name_dominio = "master1.cefaslocalserver.com"
    disk_size    = 51200
    node_name    = "master1"
  }
  master2 = {
    cpus         = 2
    memory       = 2048
    ip           = "10.17.4.22"
    name_dominio = "master2.cefaslocalserver.com"
    disk_size    = 51200
    node_name    = "master2"
  }
  master3 = {
    cpus         = 2
    memory       = 2048
    ip           = "10.17.4.23"
    name_dominio = "master3.cefaslocalserver.com"
    disk_size    = 51200
    node_name    = "master3"
  }

  # Worker Nodes (potenciados: 3 vCPU y 8 GB RAM)
  worker1 = {
    cpus         = 3
    memory       = 8192
    ip           = "10.17.4.24"
    name_dominio = "worker1.cefaslocalserver.com"
    disk_size    = 20480
    additional_disks = [
      {
        size = 40960
        type = "qcow2"
      }
    ]
    node_name = "worker1"
  }
  worker2 = {
    cpus         = 3
    memory       = 8192
    ip           = "10.17.4.25"
    name_dominio = "worker2.cefaslocalserver.com"
    disk_size    = 20480
    additional_disks = [
      {
        size = 40960
        type = "qcow2"
      }
    ]
    node_name = "worker2"
  }
  worker3 = {
    cpus         = 3
    memory       = 8192
    ip           = "10.17.4.26"
    name_dominio = "worker3.cefaslocalserver.com"
    disk_size    = 20480
    additional_disks = [
      {
        size = 40960
        type = "qcow2"
      }
    ]
    node_name = "worker3"
  }

  # Storage Node (se mantiene igual)
  storage1 = {
    cpus         = 2
    memory       = 4096
    ip           = "10.17.4.27"
    name_dominio = "storage1.cefaslocalserver.com"
    disk_size    = 10240
    additional_disks = [
      {
        size = 81920
        type = "qcow2"
      }
    ]
    node_name = "storage1"
  }
}

ssh_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdfUJjRAJuFcdO0J8CIOkjaKpqP6h9TqDRhZOJTac0199gFUvAJF9R/MAqwDLi2QI6OtYjz1CiCSVLtVQ2fTTIdwVibr+ZKDcbx/E7ivKUUbcmAOU8NP1gv3e3anoUd5k/0h0krP88CXosr41eTih4EcKhBAKbeZ11M0i9GZOux+/WweLtSQ3NU07sUkf1jDIoBungg77unmadqP3m9PUdkFP7tZ2lufcs3iq+vq8JaUBs/hZKNmWOXpnAyNxD9RlBJmvW2QgHmX53y3WC9bWUEUrwfDMB2wAqWPEDfj+5jsXQZcVE4pqD6T1cPaITnr9KFGnCCG1VQg31t1Jttg8z vhgalvez@gmail.com"
]

gateway  = "10.17.4.1"
dns1     = "10.17.3.11"
dns2     = "8.8.8.8"
timezone = "Europe/Madrid"
