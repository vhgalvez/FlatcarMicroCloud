# Hardware del Servidor

- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria**: 1093MiB / 35904MiB
- **Almacenamiento**:
  - Disco Duro Principal: 1.5TB
  - Disco Duro Secundario: 3.0TB

## Sistemas Operativos y Virtualización

- **Rocky Linux 9.3 (Blue Onyx)**
- **Rocky Linux Minimal**
- **KVM con Libvirt**: KVM/QEMU y Libvirt y Virt-Manager
- **Flatcar Container Linux**

### Configuración de Red


- **VPN con WireGuard**
- **IP Pública**
- **DHCP en KVM**
- **Redes Virtuales con KVM**
- **Firewall**
- **Modo NAT y Bridge**
- **Switch y Router**: Facilitan la comunicación y conectividad del clúster.
- **opcional Open vSwitch**: Gestión de redes virtuales y VLANs 


### Máquinas Virtuales y Sistemas Operativos

- **Bastion Node**: Rocky Linux Minimal
- **Bootstrap Node**: Rocky Linux Minimal
- **Master Nodes**: Flatcar Container Linux
- **Worker Nodes**: Flatcar Container Linux
- **FreeIPA Node**: Rocky Linux Minimal
- **Load Balancer Node**: Rocky Linux Minimal
- **PostgreSQL Node**: Rocky Linux Minimal

### Máquinas Virtuales y Roles

- **Bastion Node**: Punto de acceso seguro, modo de red Bridge, interfaz enp3s0f1
- **Bootstrap Node**: Inicializa el clúster
- **Master Nodes**: Gestión del clúster
- **Worker Nodes**: Ejecución de aplicaciones
- **FreeIPA Node**: DNS y Gestión de identidades
- **Load Balancer Node**: Traefik para balanceo de carga
- **PostgreSQL Node**: Gestión de bases de datos

### Interfaces de Red Identificadas

- **enp3s0f0**: 192.168.0.15
- **enp3s0f1**: 192.168.0.16
- **enp4s0f0**: 192.168.0.20
- **enp4s0f1**: 192.168.0.18
- **lo (Loopback)**: 127.0.0.1

Estas interfaces se utilizan para la comunicación y conectividad de la red, incluyendo la configuración de redes virtuales y la gestión de tráfico. Las interfaces están conectadas a un switch y un router de fibra óptica de la compañía de telecomunicaciones, operando bajo DHCP.

### Configuración de la Infraestructura de Red

- Las direcciones IP pueden cambiar debido a la asignación dinámica de DHCP.
- Se utilizará una infraestructura de red para configurar el modo Bridge en el nodo Bastion.

### Automatización y Orquestación

- **Terraform**: Automatización de infraestructura
- **Ansible**: Configuración y manejo de operaciones

### Microservicios en Pods

#### Análisis y Visualización de Datos

- **ELK Stack Elasticsearch**: Visualización de métricas del clúster
- **ELK Stack Kibana**: Visualización de datos
- **ELK Stack Logstash**: Procesamiento de logs
- **Prometheus**: Herramientas para el monitoreo, alertas **alertmanager** y visualización de métricas
- **Grafana**: Visualización de métricas del clúster
- **cAdvisor**: Monitorear el rendimiento y uso de recursos por parte de los contenedores
- **Nagios**: Rendimiento del sistema

#### Microservicios de Servicios de Aplicaciones

- **Nginx**: Servidor web y proxy inverso para aplicaciones web
- **Apache Kafka**: Plataforma de mensajería utilizada para la comunicación entre microservicios
- **Redis**: Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones

### Seguridad y Protección

- **Firewall**: Configuración de reglas de firewall para proteger el clúster
- **Fail2Ban**: Protección contra accesos no autorizados y ataques
- **DNS y FreeIPA**: Gestión centralizada de autenticación y políticas de seguridad y Servidor de DNS

### Almacenamiento Persistente

- **Rook y Ceph**: Orquestar Ceph en Kubernetes para almacenamiento persistente

### Especificaciones de Almacenamiento y Memoria

- **Configuración de Disco y Particiones**:
  - **/dev/sda**: 3.27 TiB
  - **/dev/sdb**: 465.71 GiB
- **Particiones**:
  - **/dev/sda1**: Sistema
  - **/dev/sda2**: 2 GB Linux Filesystem
  - **/dev/sda3**: ~2.89 TiB Linux Filesystem
- **Uso de Memoria**:
  - **Total Memory**: 35 GiB
  - **Free Memory**: 33 GiB
  - **Swap**: 17 GiB
- **Uso del Filesystem**:
  - **/dev/mapper/rl-root**: 100G (7.5G usado)
  - **/dev/sda2**: 1014M (718M usado)
  - **/dev/mapper/rl-home**: 3.0T (25G usado)

## Máquinas Virtuales y Roles

- **Total VMs**: 9
- **Roles**:
  - **Bootstrap Node**: 1 CPU, 1024 MB, inicializa clúster
  - **Master Nodes**: 3 x (2 CPUs, 2048 MB), gestionan el clúster
  - **Worker Nodes**: 3 x (2 CPUs, 2048 MB), ejecutan aplicaciones
  - **Bastion Node**: 1 CPU, 1024 MB, seguridad y acceso
  - **Load Balancer**: 1 CPU, 1024 MB, con Traefik

## Red y Conectividad

- **Switch**: TP-Link LS1008G - 8 puertos Gigabit no administrados
- **Router WiFi**: Conexión fibra óptica, 600 Mbps de subida/bajada, IP pública
- **Red**: red de kvm - Configurada con Open vSwitch para manejo avanzado y políticas de red,Gestión de redes virtuales y VLANs (opcional)
- **VPN**: WireGuard para acceso seguro ssh administrado por Bastion Node

## Redes Virtuales y Configuración

## Tabla de Configuración de Redes - kube_network_01 - Bridge Network

| Red NAT       | Nodos    | Dirección IP | Rol del Nodo                           | Interfaz de Red |
|---------------|----------|--------------|----------------------------------------|-----------------|
| br0           | bastion1 |              | Acceso seguro, Punto de conexión de bridge | `enp3s0f1`      |

## Tabla de Configuración de Redes - kube_network_02 - NAT Network

| Red NAT       | Nodos          | Dirección IP | Rol del Nodo                           | Interfaz de Red   |
|---------------|----------------|--------------|----------------------------------------|-------------------|
| kube_network_02 | freeipa1       | 10.17.3.11   | Servidor de DNS y gestión de identidades | (Virtual - NAT) |
| kube_network_02 | load_balancer1 | 10.17.3.12   | Balanceo de carga para el clúster         | (Virtual - NAT) |
| kube_network_02 | postgresql1    | 10.17.3.13   | Gestión de bases de datos                 | (Virtual - NAT) |

## Tabla de Configuración de Redes - kube_network_03 - NAT Network

| Red NAT       | Nodos        | Dirección IP | Rol del Nodo          | Interfaz de Red   |
|---------------|--------------|--------------|-----------------------|-------------------|
| kube_network_03 | bootstrap1   | 10.17.4.20   | Inicialización del clúster | (Virtual - NAT) |
| kube_network_03 | master1      | 10.17.4.21   | Gestión del clúster   | (Virtual - NAT)   |
| kube_network_03 | master2      | 10.17.4.22   | Gestión del clúster   | (Virtual - NAT)   |
| kube_network_03 | master3      | 10.17.4.23   | Gestión del clúster   | (Virtual - NAT)   |
| kube_network_03 | worker1      | 10.17.4.24   | Ejecución de aplicaciones | (Virtual - NAT) |
| kube_network_03 | worker2      | 10.17.4.25   | Ejecución de aplicaciones | (Virtual - NAT) |
| kube_network_03 | worker3      | 10.17.4.26   | Ejecución de aplicaciones | (Virtual - NAT) |

### Detalles de las Máquinas Virtuales por Red

#### kube_network_01 - Bridge Network

| Máquina  | CPU (cores) | Memoria (MB) | IP | Dominio                          | Sistema Operativo       |
|----------|-------------|--------------|----|----------------------------------|-------------------------|
| Bastion1 | 1           | 1024         |    | bastion.cefaslocalserver.com     | Rocky Linux 9.3 Minimal |

#### kube_network_02 - NAT Network

| Máquina      | CPU (cores) | Memoria (MB) | IP         | Dominio                            | Sistema Operativo |
|--------------|-------------|--------------|------------|------------------------------------|-------------------|
| FreeIPA1     | 2           | 2048         | 10.17.3.11 | freeipa1.cefaslocalserver.com      | Rocky Linux 9.3   |
| LoadBalancer1| 2           | 2048         | 10.17.3.12 | loadbalancer1.cefaslocalserver.com | Rocky Linux 9.3   |
| PostgreSQL1  | 2           | 2048         | 10.17.3.13 | postgresql1.cefaslocalserver.com   | Rocky Linux 9.3   |

#### kube_network_03 - NAT Network

| Máquina   | CPU (cores) | Memoria (MB) | IP         | Dominio                          | Sistema Operativo       |
|-----------|-------------|--------------|------------|----------------------------------|-------------------------|
| Bootstrap1| 2           | 2048         | 10.17.4.20 | bootstrap1.cefaslocalserver.com  | Flatcar Container Linux |
| Master1   | 2           | 2048         | 10.17.4.21 | master1.cefaslocalserver.com     | Flatcar Container Linux |
| Master2   | 2           | 2048         | 10.17.4.22 | master2.cefaslocalserver.com     | Flatcar Container Linux |
| Master3   | 2           | 2048         | 10.17.4.23 | master3.cefaslocalserver.com     | Flatcar Container Linux |
| Worker1   | 2           | 2048         | 10.17.4.24 | worker1.cefaslocalserver.com     | Flatcar Container Linux |
| Worker2   | 2           | 2048         | 10.17.4.25 | worker2.cefaslocalserver.com     | Flatcar Container Linux |
| Worker3   | 2           | 2048         | 10.17.4.26 | worker3.cefaslocalserver.com     | Flatcar Container Linux |

## Tabla de Configuración de Redes

### Tabla de Configuración de Redes - kube_network_01

| Red NAT          | Nodos      | Dirección IP | Rol del Nodo                               | Interfaz de Red |
|------------------|------------|--------------|--------------------------------------------|-----------------|
| kube_network_01  | `bastion1` | 192.168.0.35 | Acceso seguro, Punto de conexión de bridge | `enp3s0f1`      |

### Tabla de Configuración de Redes - kube_network_02

| Red NAT          | Nodos               | Dirección IP | Rol del Nodo                       | Interfaz de Red  |
|------------------|---------------------|--------------|------------------------------------|------------------|
| kube_network_02  | `freeipa1`          | 10.17.3.11   | Servidor de DNS y gestión de identidades | (Virtual - NAT)  |
| kube_network_02  | `load_balancer1`    | 10.17.3.12   | Balanceo de carga para el clúster  | (Virtual - NAT)  |
| kube_network_02  | `postgresql1`       | 10.17.3.13   | Gestión de bases de datos          | (Virtual - NAT)  |

### Tabla de Configuración de Redes - kube_network_03

| Red NAT          | Nodos               | Dirección IP | Rol del Nodo               | Interfaz de Red  |
|------------------|---------------------|--------------|----------------------------|------------------|
| kube_network_03  | `bootstrap1`        | 10.17.4.20   | Inicialización del clúster | (Virtual - NAT)  |
| kube_network_03  | `master1`           | 10.17.4.21   | Gestión del clúster        | (Virtual - NAT)  |
| kube_network_03  | `master2`           | 10.17.4.22   | Gestión del clúster        | (Virtual - NAT)  |
| kube_network_03  | `master3`           | 10.17.4.23   | Gestión del clúster        | (Virtual - NAT)  |
| kube_network_03  | `worker1`           | 10.17.4.24   | Ejecución de aplicaciones  | (Virtual - NAT)  |
| kube_network_03  | `worker2`           | 10.17.4.25   | Ejecución de aplicaciones  | (Virtual - NAT)  |
| kube_network_03  | `worker3`           | 10.17.4.26   | Ejecución de aplicaciones  | (Virtual - NAT)  |

### Recursos Terraform para la Configuración de Redes

```hcl
# Red br0 - Bridge Network - Rocky Linux 9.3
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

# Red kube_network_02 - NAT Network - Rocky Linux 9.3
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}

# Red kube_network_03 - NAT Network - Flatcar Container Linux
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  addresses = ["10.17.4.0/24"]
}
```

## Interfaces Físicas de Red y Funcionalidad

| Interface | IP Address    | Netmask        | Broadcast       | Description                              | Additional Info            |
|-----------|---------------|----------------|-----------------|------------------------------------------|----------------------------|
| enp3s0f0  | 192.168.0.15  | 255.255.255.0  | 192.168.0.255   | Interfaz general del servidor            | -                          |
| enp3s0f1  | 192.168.0.16  | 255.255.255.0  | 192.168.0.255   | Utilizada para Bridge en el nodo bastion1| -                          |
| enp4s0f0  | 192.168.0.20  | 255.255.255.0  | 192.168.0.255   | Otra interfaz general del servidor       | -                          |
| enp4s0f1  | 192.168.0.18  | 255.255.255.0  | 192.168.0.255   | Reserva o conexión redundante            | -                          |
| k8s       | 192.168.120.1 | 255.255.255.0  | 192.168.120.255 | Interfaz para Kubernetes                 | Solo configuración, no tráfico |
| lo        | 127.0.0.1     | 255.0.0.0      | -               | Loopback, interfaz de red virtual        | Tráfico local solo          |
| virbr0    | 192.168.122.1 | 255.255.255.0  | 192.168.122.255 | Interfaz de red virtual por defecto      | Usado típicamente por KVM   |

### Detalles Adicionales

- Los nodos dentro de cada red NAT pueden comunicarse entre sí a través de sus direcciones IP asignadas. Sin embargo, la interacción entre nodos de diferentes redes NAT requiere configuración adicional en el enrutamiento o el uso de un nodo bastión configurado para permitir y gestionar dicho tráfico.
- Consideraciones de seguridad, como firewalls y nat , deben ser tomadas en cuenta para proteger el tráfico que cruza diferentes segmentos de red y para garantizar la integridad y seguridad del clúster.
- La infraestructura de red debe apoyar estas configuraciones,bridging.
- Este diseño propuesto permite una comprensión clara de cómo se pueden estructurar y gestionar eficazmente las redes dentro de un entorno de clúster, asegurando tanto la funcionalidad como la seguridad.