### VLAN 101: Bootstrapping
| Máquina    | CPU (cores) | Memoria (MB) | IP         | Dominio                           | Sistema Operativo         |
|------------|-------------|--------------|------------|-----------------------------------|---------------------------|
| Bootstrap1 | 1           | 1024         | 10.17.3.10 | bootstrap.cefaslocalserver.com    | Flatcar Container Linux   |

### VLAN 102: Masters
| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Sistema Operativo         |
|---------|-------------|--------------|------------|---------------------------------|---------------------------|
| Master1 | 2           | 2048         | 10.17.3.11 | master1.cefaslocalserver.com    | Flatcar Container Linux   |
| Master2 | 2           | 2048         | 10.17.3.12 | master2.cefaslocalserver.com    | Flatcar Container Linux   |
| Master3 | 2           | 2048         | 10.17.3.13 | master3.cefaslocalserver.com    | Flatcar Container Linux   |

### VLAN 103: Workers
| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Sistema Operativo         |
|---------|-------------|--------------|------------|---------------------------------|---------------------------|
| Worker1 | 2           | 2048         | 10.17.3.14 | worker1.cefaslocalserver.com    | Flatcar Container Linux   |
| Worker2 | 2           | 2048         | 10.17.3.15 | worker2.cefaslocalserver.com    | Flatcar Container Linux   |
| Worker3 | 2           | 2048         | 10.17.3.16 | worker3.cefaslocalserver.com    | Flatcar Container Linux   |

### VLAN 104: Management and Utility
| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Modo de Red | Sistema Operativo       |
|----------|-------------|--------------|------------|---------------------------------|-------------|-------------------------|
| Bastion1 | 1           | 1024         | 10.17.3.21 | bastion.cefaslocalserver.com    | Bridge      | Rocky Linux 9.3 Minimal |

### VLAN 105: Storage and Databases
| Máquina     | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Sistema Operativo       |
|-------------|-------------|--------------|------------|---------------------------------|-------------------------|
| NFS1        | 1           | 1024         | 10.17.3.19 | nfs.cefaslocalserver.com        | Rocky Linux 9.3 Minimal |
| PostgreSQL1 | 1           | 1024         | 10.17.3.20 | postgresql.cefaslocalserver.com | Rocky Linux 9.3 Minimal |

### VLAN 106: Load Balancing
| Máquina       | CPU (cores) | Memoria (MB) | IP         | Dominio                           | Sistema Operativo       |
|---------------|-------------|--------------|------------|-----------------------------------|-------------------------|
| Load Balancer1| 1           | 1024         | 10.17.3.18 | loadbalancer.cefaslocalserver.com | Rocky Linux 9.3 Minimal |

### VLAN 107: Identity Management
| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                       | Sistema Operativo       |
|----------|-------------|--------------|------------|-------------------------------|-------------------------|
| FreeIPA1 | 1           | 1024         | 10.17.3.17 | dns.cefaslocalserver.com      | Rocky Linux 9.3 Minimal |

### Análisis y Visualización de Datos
| Máquina       | CPU (cores) | Memoria (MB) | IP         | Dominio                           | Sistema Operativo       |
|---------------|-------------|--------------|------------|-----------------------------------|-------------------------|
| Elasticsearch1| 2           | 2048         | 10.17.3.22 | elasticsearch.cefaslocalserver.com| Rocky Linux 9.3 Minimal |
| Kibana1       | 1           | 1024         | 10.17.3.23 | kibana.cefaslocalserver.com       | Rocky Linux 9.3 Minimal |
