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
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]

gateway  = "10.17.4.1"
dns1     = "10.17.3.11"
dns2     = "8.8.8.8"
timezone = "Europe/Madrid"
