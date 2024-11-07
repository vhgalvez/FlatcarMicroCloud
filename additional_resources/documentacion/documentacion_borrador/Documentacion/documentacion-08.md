### VLAN 101

#### Máquinas Virtuales (KVM)

| Máquina    | CPU (cores) | Memoria (MB) | IP         | Dominio                        |
| ---------- | ----------- | ------------ | ---------- | ------------------------------ |
| Bootstrap1 | 1           | 1024         | 10.17.3.10 | bootstrap.cefaslocalserver.com |

### VLAN 102

#### Máquinas Virtuales (KVM)

| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                      |
| ------- | ----------- | ------------ | ---------- | ---------------------------- |
| Master1 | 2           | 2048         | 10.17.3.11 | master1.cefaslocalserver.com |
| Master2 | 2           | 2048         | 10.17.3.12 | master2.cefaslocalserver.com |
| Master3 | 2           | 2048         | 10.17.3.13 | master3.cefaslocalserver.com |

### VLAN 103

#### Máquinas Virtuales (KVM)

| Máquina | CPU (cores) | Memoria (MB) | IP         | Dominio                      |
| ------- | ----------- | ------------ | ---------- | ---------------------------- |
| Worker1 | 2           | 2048         | 10.17.3.14 | worker1.cefaslocalserver.com |
| Worker2 | 2           | 2048         | 10.17.3.15 | worker2.cefaslocalserver.com |
| Worker3 | 2           | 2048         | 10.17.3.16 | worker3.cefaslocalserver.com |

### VLAN 104

### VLAN 104

#### Máquinas Virtuales (KVM)

| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                      | Modo de Red |
| -------- | ----------- | ------------ | ---------- | ---------------------------- | ----------- |
| Bastion1 | 1           | 1024         | 10.17.3.21 | bastion.cefaslocalserver.com | Bridge      |

### VLAN 105

#### Máquinas Virtuales (KVM)

| Máquina     | CPU (cores) | Memoria (MB) | IP         | Dominio                         |
| ----------- | ----------- | ------------ | ---------- | ------------------------------- |
| NFS1        | 1           | 1024         | 10.17.3.19 | nfs.cefaslocalserver.com        |
| PostgreSQL1 | 1           | 1024         | 10.17.3.20 | postgresql.cefaslocalserver.com |

### VLAN 106

#### Máquinas Virtuales (KVM)

| Máquina        | CPU (cores) | Memoria (MB) | IP         | Dominio                           |
| -------------- | ----------- | ------------ | ---------- | --------------------------------- |
| Load Balancer1 | 1           | 1024         | 10.17.3.18 | loadbalancer.cefaslocalserver.com |

### VLAN 107

#### Máquinas Virtuales (KVM)

| Máquina  | CPU (cores) | Memoria (MB) | IP         | Dominio                  |
| -------- | ----------- | ------------ | ---------- | ------------------------ |
| FreeIPA1 | 1           | 1024         | 10.17.3.17 | dns.cefaslocalserver.com |

### Análisis y Visualización de Datos

#### Máquinas Virtuales (KVM)

| Máquina        | CPU (cores) | Memoria (MB) | IP         | Dominio                            |
| -------------- | ----------- | ------------ | ---------- | ---------------------------------- |
| Elasticsearch1 | 2           | 2048         | 10.17.3.22 | elasticsearch.cefaslocalserver.com |
| Kibana1        | 1           | 1024         | 10.17.3.23 | kibana.cefaslocalserver.com        |
