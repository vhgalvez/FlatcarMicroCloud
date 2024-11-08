# Documento Técnico: FlatcarMicroCloud en Entorno Kubernetes

## Descripción General del Proyecto

FlatcarMicroCloud es un entorno Kubernetes optimizado para servidores físicos, diseñado para implementar aplicaciones en contenedores y servicios de microservicios. Esta solución usa K3s como Kubernetes ligero, Rook y Ceph para almacenamiento persistente, y una combinación de herramientas para la comunicación entre microservicios, monitoreo y escalabilidad. Se despliega en un servidor físico ProLiant DL380 G7 con Rocky Linux 9.4 y KVM.

---

## Resumen de Recursos para Máquinas Virtuales

| Nombre de VM       | CPU | Memoria (MB) | IP            | Nombre de Dominio                  | Tamaño de Disco (MB) | Hostname   |
|--------------------|-----|--------------|---------------|------------------------------------|-----------------------|------------|
| master1            | 2   | 4096         | 10.17.4.21    | master1.cefaslocalserver.com       | 51200 (50 GB)        | master1    |
| master2            | 2   | 4096         | 10.17.4.22    | master2.cefaslocalserver.com       | 51200 (50 GB)        | master2    |
| master3            | 2   | 4096         | 10.17.4.23    | master3.cefaslocalserver.com       | 51200 (50 GB)        | master3    |
| worker1            | 2   | 3584         | 10.17.4.24    | worker1.cefaslocalserver.com       | 51200 (50 GB)        | worker1    |
| worker2            | 2   | 3584         | 10.17.4.25    | worker2.cefaslocalserver.com       | 51200 (50 GB)        | worker2    |
| worker3            | 2   | 3584         | 10.17.4.26    | worker3.cefaslocalserver.com       | 51200 (50 GB)        | worker3    |
| bootstrap          | 2   | 3584         | 10.17.4.27    | bootstrap.cefaslocalserver.com     | 51200 (50 GB)        | bootstrap  |
| freeipa1           | 2   | 2048         | 10.17.3.11    | freeipa1.cefaslocalserver.com      | 32212 (32 GB)        | freeipa1   |
| load_balancer1     | 2   | 2048         | 10.17.3.12    | loadbalancer1.cefaslocalserver.com | 32212 (32 GB)        | loadbalancer1 |
| postgresql1        | 2   | 2048         | 10.17.3.13    | postgresql1.cefaslocalserver.com   | 32212 (32 GB)        | postgresql1 |
| helper             | 2   | 2048         | 10.17.3.14    | helper.cefaslocalserver.com        | 32212 (32 GB)        | helper_node |

---

## Detalles de Configuración

- **Imágenes Base**:
  - Fedora CoreOS: `/mnt/lv_data/organized_storage/images/fedora-coreos-40.20240906.3.0-qemu.x86_64.qcow2`
  - Rocky Linux: `/mnt/lv_data/organized_storage/images/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2`

- **Red Gateway**:
  - kube_network_03: 10.17.4.1
  - kube_network_02: 10.17.3.1

- **DNS**:
  - Primario: 10.17.3.11 (FreeIPA)
  - Secundario: 8.8.8.8

- **Zona Horaria**:
  - Europe/London

- **Clave SSH**:
  - Clave pública SSH incluida para acceso seguro a las VMs.

---

## Explicación de Roles de las VMs

- **Maestros (master1, master2, master3)**:
  - Nodos que conforman el plano de control de Kubernetes, manejando la API y distribuyendo la carga en los nodos worker.

- **Workers (worker1, worker2, worker3)**:
  - Nodos responsables de ejecutar aplicaciones en contenedores y manejar la carga de trabajo del clúster.

- **Bootstrap**:
  - Nodo utilizado para iniciar y configurar el clúster.

- **FreeIPA (freeipa1)**:
  - Nodo que actúa como servidor DNS y de autenticación, proporcionando gestión de nombres y autenticación centralizada.

- **Load Balancer (load_balancer1)**:
  - Nodo que utiliza Traefik para gestionar la distribución de tráfico entre los nodos del clúster.

- **PostgreSQL (postgresql1)**:
  - Nodo dedicado para la base de datos, proporcionando almacenamiento persistente para las aplicaciones de microservicios.

- **Helper**:
  - Nodo auxiliar para tareas administrativas y de soporte dentro del clúster.

---

## Análisis de Recursos

### Hardware del Servidor
- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria Total**: 35 GB RAM
- **Almacenamiento**:
  - Disco Principal: 1.5TB
  - Disco Secundario: 3.0TB

### Configuración de Red
- **VPN**: Configuración de VPN con WireGuard para seguridad y acceso remoto.
- **DHCP en KVM**: Gestiona las asignaciones IP de las VMs.
- **Firewall y NAT**: Aseguran la protección de tráfico entrante y la configuración de redes virtuales con bridge y VLANs.

---

## Optimización para Producción

### Restricciones de Recursos
- Asigna límites en Kubernetes para cada servicio (Prometheus, PostgreSQL, Jenkins, Kafka, Redis) para evitar el consumo excesivo de recursos y proteger el rendimiento general del sistema.

### Control de Logs y Monitoreo
- Define políticas de retención de logs en Prometheus y Kafka para reducir el uso de disco.

### Supervisión Activa
- Grafana proporciona monitoreo en tiempo real, permitiendo ajustes proactivos de recursos en función de la carga detectada.

---

## Diagramas de Red y Arquitectura

```bash
                 +---------------------------+                       
                 |        IP Pública         |                       
                 |       (HTTPS)             |
                 |       192.168.0.21        |                       
                 +---------------------------+                       
                             |                                     
                             v                                     
                 +---------------------------+                       
                 |       Bastion Node        |                       
                 |        SSH Access         |                       
                 |      IP: 192.168.0.20     |                       
                 +---------------------------+                       
                             |                                     
                             v                                     
                 +---------------------------+                       
                 |      Load Balancer        |                       
                 |         Traefik           |                       
                 |      IP: 10.17.3.12       |                       
                 +---------------------------+                       
                             |                                     
            +----------------+---------------+-----------------+                  
            |                |               |                 |
            v                v               v                 v  
     +------+-------+   +----+-------+   +----+-------+   +----+-------+       
     |   Master     |   |   Worker    |   |   Worker    |   |   Worker    |      
     |    Node      |   |     1       |   |     2       |   |     3       |
     | IP: 10.17.4.21|   | IP: 10.17.4.24|   | IP: 10.17.4.25|   | IP: 10.17.4.23|    
     +------+-------+   +----+-------+   +----+-------+   +----+-------+          
             |              |                |                 |                 
             +--------------+----------------+-----------------+-----------------+
                            |                                    |       
                            v                                    v       
              +-------------+-------------+           +----------+----------+
              |        Redis Cache        |           |       Apache Kafka     |
              |       (In-memory)         |           |       (Message Queue)  |
              +---------------------------+           +------------------------+
                             |                                     
                             v                                     
                 +---------------------------+                       
                 |       FreeIPA Node        |                       
                 |         DNS/Auth          |                       
                 |      IP: 10.17.3.11       |                       
                 +---------------------------+                       
                             |                                     
                             v                                     
                 +---------------------------+                         
                 |     PostgreSQL Node       |                         
                 |      IP: 10.17.3.13       |                         
                 +---------------------------+ 
```
