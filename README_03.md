# FlatcarMicroCloud: Entorno Kubernetes Optimizado para Servidores Físicos con Comunicación de Microservicios y Escalabilidad

## Descripción General

FlatcarMicroCloud es una solución Kubernetes diseñada para maximizar los recursos de un servidor físico, en este caso, el ProLiant DL380 G7 ejecutando Rocky Linux 9.4. FlatcarMicroCloud facilita el despliegue de aplicaciones en contenedores con herramientas como K3s para Kubernetes ligero, Rook y Ceph para almacenamiento persistente y monitoreo avanzado con Prometheus y Grafana. Este entorno optimizado permite una administración eficiente y escalabilidad. Ahora incluye comunicación entre microservicios con Apache Kafka y MQTT Mosquitto, y Redis para escalabilidad de base de datos en RAM.

## Análisis de Recursos

| Recurso              | Descripción                                                                                                               |
|----------------------|---------------------------------------------------------------------------------------------------------------------------|
| **CPU**              | Intel Xeon X5650 (24 hilos a 2.666 GHz). Adecuado para manejar cargas de Kubernetes, FastAPI, Redis, Kafka y Mosquitto.   |
| **Memoria RAM**      | 35 GB de RAM, suficiente para el clúster y servicios de escalabilidad como Redis y almacenamiento de mensajes en Kafka.   |
| **Almacenamiento I/O** | Almacenamiento confiable para PostgreSQL, Kafka y logs. Ceph facilita el almacenamiento distribuido y Rook asegura la persistencia. |

## Optimización para Producción

| Aspecto                       | Detalle                                                                                                           |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------|
| **Restricción de Recursos**   | Configura límites en Kubernetes para cada servicio (Prometheus, PostgreSQL, Jenkins, Kafka, Redis).               |
| **Control de Logs y Monitoreo** | Define políticas de retención de logs en Prometheus y Kafka para reducir el consumo de disco.                     |
| **Supervisión Activa**        | Usa Grafana para monitoreo en tiempo real, ajustando recursos según los picos de carga detectados.                |

Estas optimizaciones aseguran un entorno escalable y eficiente para producción.

---

## Hardware del Servidor

- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria**: 1093MiB / 35904MiB
- **Almacenamiento**:
  - Disco Duro Principal: 1.5TB
  - Disco Duro Secundario: 3.0TB

---

## Sistemas Operativos y Virtualización

- **Rocky Linux 9.3 (Blue Onyx)**
- **Flatcar Container Linux**
- **KVM con Libvirt**: kvm/qemu, libvirt y Virt-Manager

### Configuración de Red

- **VPN con WireGuard**
- **IP Pública**
- **DHCP en KVM**
- **Firewall**
- **Modo NAT y Bridge**: Configuración de redes virtuales y VLANs con KVM
- **Switch y Router**: Facilitan la comunicación y conectividad del clúster.

---
## FreeIPA (10.17.3.11)

- **Servidor DNS y NTP (chronyc)**:
    FreeIPA actúa como el servidor DNS, gestionando la resolución de nombres y autenticación dentro del clúster. Además, **chronyc** está configurado para sincronizar el tiempo en todo el clúster, utilizando FreeIPA como uno de los servidores NTP principales.

## Chronyc / NTP

- **Sincronización de tiempo**: 
    FreeIPA también proporciona servicios NTP. Todos los nodos del clúster, incluyendo los nodos maestros, workers y el Bootstrap Node, sincronizan su tiempo utilizando **chronyc** y el servidor NTP de FreeIPA (`10.17.3.11`). Esto garantiza que todos los nodos mantengan una sincronización temporal precisa, lo cual es crucial para la operación correcta de Kubernetes y otros servicios distribuidos.

---

## Máquinas Virtuales y Roles

| Nodo                    | Sistema Operativo         | Función                                         | Cantidad |
|-------------------------|---------------------------|-------------------------------------------------|----------|
| **Bastion Node**        | Rocky Linux               | Acceso seguro y conexiones SSH al clúster       | 1        |
| **Load Balancer Node**  | Rocky Linux               | Balanceo de tráfico con Traefik                 | 1        |
| **FreeIPA Node**        | Rocky Linux               | DNS y autenticación                             | 1        |
| **PostgreSQL Node**     | Rocky Linux               | Base de datos central para microservicios       | 1        |
| **Master Node**         | Flatcar Container Linux   | Administración de API de Kubernetes             | 1        |
| **Worker Nodes**        | Flatcar Container Linux   | Ejecución de microservicios y aplicaciones      | 3        |
| **Bootstrap Node**      | Flatcar Container Linux   | Nodo inicial para configurar el clúster         | 1        |

### Interfaces de Red Identificadas

| Interfaz     | Dirección IP    |
|--------------|-----------------|
| **enp3s0f0** | 192.168.0.15    |
| **enp3s0f1** | 192.168.0.16    |
| **enp4s0f0** | 192.168.0.20    |
| **enp4s0f1** | 192.168.0.18    |
| **lo**       | 127.0.0.1       |

Estas interfaces están conectadas a un switch y un router de fibra óptica, operando bajo DHCP y facilitando la conectividad y administración del clúster.

---

## Configuración de Redes Virtuales

### Red br0 - Bridge Network

| Red NAT | Nodos    | Dirección IP | Rol del Nodo                              | Interfaz de Red |
|---------|----------|--------------|-------------------------------------------|-----------------|
| br0     | bastion1 | 192.168.0.20 | Acceso seguro, Punto de conexión de bridge| enp3s0f1        |

### Red kube_network_02 - NAT Network

| Red NAT         | Nodos          | Dirección IP | Rol del Nodo                            | Interfaz de Red |
|-----------------|----------------|--------------|-----------------------------------------|-----------------|
| kube_network_02 | freeipa1       | 10.17.3.11   | Servidor de DNS y gestión de identidades| (Virtual - NAT) |
| kube_network_02 | load_balancer1 | 10.17.3.12   | Balanceo de carga para el clúster       | (Virtual - NAT) |
| kube_network_02 | postgresql1    | 10.17.3.13   | Gestión de bases de datos               | (Virtual - NAT) |
| kube_network_02 | bootstrap1     | 10.17.3.14   | Inicialización del clúster              | (Virtual - NAT) |

### Red kube_network_03 - NAT Network

| Red NAT         | Nodos    | Dirección IP | Rol del Nodo                   | Interfaz de Red |
|-----------------|----------|--------------|--------------------------------|-----------------|
| kube_network_03 | master1  | 10.17.4.21   | Gestión del clúster            | (Virtual - NAT) |
| kube_network_03 | worker1  | 10.17.4.24   | Ejecución de aplicaciones       | (Virtual - NAT) |
| kube_network_03 | worker2  | 10.17.4.25   | Ejecución de aplicaciones       | (Virtual - NAT) |
| kube_network_03 | worker3  | 10.17.4.26   | Ejecución de aplicaciones       | (Virtual - NAT) |

---

## Fase 2: Instalación y Configuración de K3s en el Clúster de Kubernetes

1. **Instalación en el Nodo Bootstrap**: Instala K3s en el nodo Bootstrap con configuraciones específicas.
2. **Configuración de Nodos Master y Worker**: Define roles de los nodos y despliega Traefik como balanceador.

---

## Fase 3: Configuración de PostgreSQL

| Aspecto                 | Configuración                                                                              |
|-------------------------|--------------------------------------------------------------------------------------------|
| **Servidor**            | `postgresql1.cefaslocalserver.com`                                                         |
| **Permisos**            | Ajusta permisos para permitir el acceso de microservicios en el clúster.                   |
| **Respaldo y Recuperación** | Define políticas para almacenamiento y recuperación de datos.                           |

---

## Fase 4: Desarrollo e Implementación de Microservicios con Comunicación Asíncrona

### 1. Comunicación de Microservicios con Apache Kafka y MQTT Mosquitto

| Componente             | Descripción                                                                                                           |
|------------------------|-----------------------------------------------------------------------------------------------------------------------|
| **Apache Kafka**       | Canal de comunicación asíncrona entre microservicios, ideal para manejar flujos de datos de alto volumen y eventos.  |
| **MQTT Mosquitto**     | Protocolo ligero para notificaciones en tiempo real entre microservicios y dispositivos IoT.                         |

### 2. Escalabilidad con Redis para Bases de Datos en RAM

| Componente | Descripción                                                                                |
|------------|--------------------------------------------------------------------------------------------|
| **Redis**  | Base de datos en memoria para escalabilidad rápida y almacenamiento en caché de alta velocidad.|

---

## Fase 5: Desarrollo del Frontend con Vue.js

- Usa **Vue.js** para desarrollar la interfaz de usuario, conectada a las APIs de FastAPI.
- Despliega el frontend en K3s y configúralo para acceso mediante el Load Balancer (Traefik).

---

# Resumen de los Hostnames e IPs

A continuación se proporciona un resumen de los hostnames e IPs para referencia rápida. Esta tabla es crucial para la gestión y monitorización del entorno, permitiendo una identificación rápida de cada nodo y su rol.

| Dirección IP  | Hostname                        |
|---------------|---------------------------------|
| 10.17.3.11    | freeipa1.cefaslocalserver.com   |
| 10.17.3.12    | load_balancer1.cefaslocalserver.com |
| 10.17.3.13    | postgresql1.cefaslocalserver.com |
| 10.17.4.22    | master.cefaslocalserver.com    |
| 10.17.4.25    | worker1.cefaslocalserver.com    |
| 10.17.4.26    | worker2.cefaslocalserver.com    |
| 10.17.4.27    | worker3.cefaslocalserver.com    |
| 10.17.4.21    | bootstrap.cefaslocalserver.com |

### Automatización y Orquestación

- **Terraform**: Automatización de infraestructura
- **Ansible**: Configuración y manejo de operaciones

### Microservicios en pods

#### Análisis y Visualización de Datos

- **ELK Stack Elasticsearch**: Visualización de métricas del clúster
- **ELK Stack Kibana**: Visualización de datos
- **ELK Stack Logstash**: Procesamiento de logs
- **Prometheus**: Herramientas para el monitoreo , alertas **alertmanager** y visualización de métricas
- **Grafana**: Visualización de métricas del clúster
- **cAdvisor**: Monitorear el rendimiento y uso de recursos por parte de los contenedores.
- **Nagios**: Rendimiento del sistema

#### Microservicios de servicios de Aplicaciones

- **Nginx:** Servidor web y proxy inverso para aplicaciones web.
- **Apache Kafka:** Plataforma de mensajería utilizada para la comunicación entre microservicios.
- **Redis:** Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.

### Seguridad y Protección

- **Firewall** : Configuración de reglas de firewall para proteger el clúster.
- **Fail2Ban**: Protección contra accesos no autorizados y ataques.
- **DNS y FreeIPA**: Gestión centralizada de autenticación y políticas de seguridad y Servidor de DNS

### Almacenamiento persistente

**Rook y Ceph** Rook Orquestar Ceph en Kubernetes para almacenamiento persistente.

### Especificaciones de Almacenamiento y Memoria

- **Configuración de Disco y Particiones**:
  - **/dev/sda**: 3.27 TiB
  - **/dev/sdb**: 465.71 GiB
- **Particiones**:
  - **/dev/sda1**: Sistema
  - **/dev/sda2**: 2 GB Linux Filesystem
  - **/dev/sda3**: ~2.89 TiB Linux Filesystem
- **Uso de Memoria**:
  - **Total Memory**: 35GiB
  - **Free Memory**: 33GiB
  - **Swap**: 17GiB
- **Uso del Filesystem**:
  - **/dev/mapper/rl-root**: 100G (7.5G usado)
  - **/dev/sda2**: 1014M (718M usado)
  - **/dev/mapper/rl-home**: 3.0T (25G usado)

## Máquinas Virtuales y Roles

- **Total VMs**: 11
- **Roles**:
  - **Bootstrap Node**: 2 CPUs, 2048 MB, inicializa el clúster
  - **Master Nodes**: 3 x (2 CPUs, 4096 MB), gestionan el clúster
  - **Worker Nodes**: 3 x (2 CPUs, 3584 MB), ejecutan aplicaciones
  - **Bastion Node**: 2 CPUs, 2048 MB, seguridad y acceso
  - **Load Balancer**: 2 CPUs, 2048 MB, con Traefik
  - **FreeIPA Node**: 2 CPUs, 2048 MB, servidor de DNS y gestión de identidades
  - **PostgreSQL Node**: 2 CPUs, 2048 MB, gestión de bases de datos
  
## Red y Conectividad

- **Switch**: TP-Link LS1008G - 8 puertos Gigabit no administrados
- **Router WiFi**: Conexión fibra óptica, 600 Mbps de subida/bajada, IP pública
- **Red**: Configurada red NAT y red Bridge de kvm
- **VPN**: WireGuard para acceso seguro ssh administrado por Bastion Node
---


# Configuración de Redes Virtuales

### Red br0 - Bridge Network

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
```

### Red kube_network_02 - NAT Network

```hcl
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}
```

### Red kube_network_03 - NAT Network

```hcl
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
```

## Diagrama de Nodos y Conexiones


```bash
                 +---------------------------+                        
                 |        IP Pública         |                       
                 |         (HTTPS)           |
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
     | Master Node 1 |   |   Worker    |   |   Worker    |   |   Worker    |      
     |    (etcd)     |   |     1       |   |     2       |   |     3       |
     | IP: 10.17.4.21|   | IP: 10.17.4.24|   | IP: 10.17.4.25|   | IP: 10.17.4.26|    
     +---------------+   +--------------+   +--------------+   +--------------+          
             |                                                   
             |        +----------------------------------------+
             |        |                                        |
             |        v                                        v
     +---------------------+                           +---------------------+
     |     Master Node 2   |                           |     Master Node 3   |
     |       (etcd)        |                           |       (etcd)        |
     |     IP: 10.17.4.22  |                           |     IP: 10.17.4.23  |
     +---------------------+                           +---------------------+
             |                                                                  
             +----------------------------------------------------------------+
                                                                              
                          |                                          |
                          v                                          v       
               +-------------+-------------+            +-------------+-------------+
               |        Redis Cache        |            |        Apache Kafka       |
               |       (In-memory)         |            |       (Message Queue)     |
               +---------------------------+            +---------------------------+
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




## Información del Sistema

```bash
        #####           victory@physical1.cefaslocalserver.com
       #######          --------------------------------------
       ##O#O##          OS: Rocky Linux 9.4 (Blue Onyx) x86_64
       #######          Host: ProLiant DL380 G7
     ###########        Kernel: 5.14.0-427.22.1.el9_4.x86_64
    #############       Uptime: 3 hours, 5 mins
   ###############      Packages: 1301 (rpm)
   ################     Shell: bash 5.1.8
  #################     Resolution: 1024x768
#####################   Terminal: /dev/pts/16
#####################   CPU: Intel Xeon X5650 (24) @ 2.665GHz
  #################     GPU: AMD ATI 01:03.0 ES1000
   ################
                        Memory: 21362MiB / 35904MiB
```

# Resumen del Flujo

1. Las **conexiones HTTPS** externas ingresan por la **IP pública (192.168.0.21)**.
2. El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al
5. **FreeIPA** actúa como **servidor DNS y NTP**, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con FreeIPA a través de **chronyc**.


## Resumen de Recursos para Máquinas Virtuales

| Nombre de VM       | CPU | Memoria (MB) | IP            | Nombre de Dominio                  | Tamaño de Disco (MB) | Hostname   |
|--------------------|-----|--------------|---------------|------------------------------------|-----------------------|------------|
| master1            | 2   | 4096         | 10.17.4.21    | master1.cefaslocalserver.com       | 51200 (50 GB)        | master1    |
| master2            | 2   | 4096         | 10.17.4.22    | master2.cefaslocalserver.com       | 51200 (50 GB)        | master2    |
| master3            | 2   | 4096         | 10.17.4.23    | master3.cefaslocalserver.com       | 51200 (50 GB)        | master3    |
| worker1            | 2   | 4096         | 10.17.4.24    | worker1.cefaslocalserver.com       | 51200 (50 GB)        | worker1    |
| worker2            | 2   | 4096         | 10.17.4.25    | worker2.cefaslocalserver.com       | 51200 (50 GB)        | worker2    |
| worker3            | 2   | 4096         | 10.17.4.26    | worker3.cefaslocalserver.com       | 51200 (50 GB)        | worker3    |
| bootstrap          | 2   | 4096         | 10.17.4.27    | bootstrap.cefaslocalserver.com     | 51200 (50 GB)        | bootstrap  |
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

## Estructura del Proyecto

- `br0_network/`
- `nat_network_02/`
- `nat_network_03/`

## Requisitos

- [Terraform](https://www.terraform.io/downloads.html) v0.13 o superior
- Acceso a un servidor KVM con libvirt

## Instrucciones de Ejecución


Clonar el Repositorio de Terraform

Clona el repositorio que contiene tu configuración de Terraform.

```bash
git clone https://github.com/vhgalvez/FlatcarMicroCloud.git
cd FlatcarMicroCloud
```

### Inicializar y Aplicar Terraform para `br0_network`



1. Navegue al directorio `br0_network`:

   ```bash
   cd br0_network
   ```

2. Inicialice Terraform y actualice los proveedores:

   ```bash
   sudo terraform init --upgrade
   ```

3. Aplique la configuración de Terraform:

   ```bash
   sudo terraform apply
   ```

### Inicializar y Aplicar Terraform para `nat_network_02`

1. Navegue al directorio `nat_network_02`:

   ```bash
   cd ../nat_network_02
   ```

2. Inicialice Terraform y actualice los proveedores:

   ```bash
   sudo terraform init --upgrade
   ```

3. Aplique la configuración de Terraform:

   ```bash
   sudo terraform apply
   ```

### Inicializar y Aplicar Terraform para `nat_network_03`

1. Navegue al directorio `nat_network_03`:

   ```bash
   cd ../nat_network_03
   ```

2. Inicialice Terraform y actualice los proveedores:

   ```bash
   sudo terraform init --upgrade
   ```

3. Aplique la configuración de Terraform:

   ```bash
   sudo terraform apply
   ```


## Notas Adicionales

- Asegúrese de tener las variables y configuraciones adecuadas en los archivos `terraform.tfvars` de cada subproyecto.
- Cada subproyecto tiene su propio `main.tf` y configuración de variables, por lo que no debería haber conflictos de nombres si sigue las instrucciones anteriores.
- Puede ajustar las configuraciones y variables según sea necesario para adaptarse a su entorno y necesidades específicas.
