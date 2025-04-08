# nat_network_03\terraform.tfvars
base_image = "/mnt/lv_data/organized_storage/images/flatcar_production_qemu_image.img"

vm_definitions = {
  # Master Nodes (cada uno: 50 GB disco principal, sin discos extra)
  master1 = {
    cpus         = 4
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.21"
    name_dominio = "master1.cefaslocalserver.com"
    disk_size    = 51200  # 50 GB disco principal
    node_name    = "master1"
  }
  master2 = {
    cpus         = 4
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.22"
    name_dominio = "master2.cefaslocalserver.com"
    disk_size    = 51200  # 50 GB disco principal
    node_name    = "master2"
  }
  master3 = {
    cpus         = 4
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.23"
    name_dominio = "master3.cefaslocalserver.com"
    disk_size    = 51200  # 50 GB disco principal
    node_name    = "master3"
  }

  # Worker Nodes (20 GB OS + 40 GB adicional para Longhorn)
  worker1 = {
    cpus         = 2
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.24"
    name_dominio = "worker1.cefaslocalserver.com"
    disk_size    = 20480  # 20 GB disco principal (Flatcar OS)
    additional_disks = [
      {
        size = 40960  # 40 GB disco adicional para Longhorn
        type = "qcow2"
      }
    ]
    node_name = "worker1"
  }
  worker2 = {
    cpus         = 2
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.25"
    name_dominio = "worker2.cefaslocalserver.com"
    disk_size    = 20480  # 20 GB disco principal (Flatcar OS)
    additional_disks = [
      {
        size = 40960  # 40 GB disco adicional para Longhorn
        type = "qcow2"
      }
    ]
    node_name = "worker2"
  }
  worker3 = {
    cpus         = 2
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.26"
    name_dominio = "worker3.cefaslocalserver.com"
    disk_size    = 20480  # 20 GB disco principal (Flatcar OS)
    additional_disks = [
      {
        size = 40960  # 40 GB disco adicional para Longhorn
        type = "qcow2"
      }
    ]
    node_name = "worker3"
  }

  # Storage Node (10 GB OS + 80 GB para NFS y backups Longhorn)
  storage1 = {
    cpus         = 2
    memory       = 4096  # 4 GB RAM
    ip           = "10.17.4.27"
    name_dominio = "storage1.cefaslocalserver.com"
    disk_size    = 10240  # 10 GB disco principal
    additional_disks = [
      {
        size = 81920  # 80 GB disco adicional (NFS + backups Longhorn)
        type = "qcow2"
      }
    ]
    node_name = "storage1"
  }
}

# Llaves SSH públicas
ssh_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDC9XqGWEd2de3Ud8TgvzFchK2/SYh+WHohA1KEuveXjCbse9aXKmNAZ369vaGFFGrxbSptMeEt41ytEFpU09gAXM6KSsQWGZxfkCJQSWIaIEAdft7QHnTpMeronSgYZIU+5P7/RJcVhHBXfjLHV6giHxFRJ9MF7n6sms38VsuF2s4smI03DWGWP6Ro7siXvd+LBu2gDqosQaZQiz5/FX5YWxvuhq0E/ACas/JE8fjIL9DQPcFrgQkNAv1kHpIWRqSLPwyTMMxGgFxGI8aCTH/Uaxbqa7Qm/aBfdG2lZBE1XU6HRjAToFmqsPJv4LkBxaC1Ag62QPXONNxAA97arICr vhgalvez@gmail.com"
]

gateway = "10.17.4.1"
dns1    = "10.17.3.11"
dns2    = "8.8.8.8"
timezone = "Europe/Madrid"