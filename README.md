# FlatcarMicroCloud: Entorno Kubernetes Optimizado para Servidores Físicos

## Descripción General del Proyecto

FlatcarMicroCloud es una solución Kubernetes diseñada para maximizar los recursos de un servidor físico, en este caso, el ProLiant DL380 G7 ejecutando Rocky Linux 9.4. Permite desplegar aplicaciones en contenedores utilizando herramientas como K3s para Kubernetes ligero, Rook y Ceph para almacenamiento persistente, monitoreo avanzado con Prometheus y Grafana, y Apache Kafka y MQTT Mosquitto para comunicación entre microservicios.

## Hardware del Servidor

- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI ES1000
- **Memoria Total**: 35 GB RAM
- **Almacenamiento**:
  - Disco Principal: 1.5TB
  - Disco Secundario: 3.0TB

## Sistemas Operativos y Virtualización

- **Sistemas Operativos**: Rocky Linux 9.4 y Flatcar Container Linux
- **Virtualización**: KVM con Libvirt y Virt-Manager
- **Configuración de Red**: VPN con WireGuard, DHCP, firewall, y configuraciones de redes virtuales (NAT y Bridge) con KVM.
- **Switch y Router**: Facilitan la comunicación y conectividad del clúster.

## Resumen de Recursos para Máquinas Virtuales

| Nombre de VM  | CPU | Memoria (MB) | IP         | Nombre de Dominio                  | Tamaño de Disco (GB) | Hostname      |
| ------------- | --- | ------------ | ---------- | ---------------------------------- | -------------------- | ------------- |
| master1       | 2   | 4096         | 10.17.4.21 | master1.cefaslocalserver.com       | 50                   | master1       |
| master2       | 2   | 4096         | 10.17.4.22 | master2.cefaslocalserver.com       | 50                   | master2       |
| master3       | 2   | 4096         | 10.17.4.23 | master3.cefaslocalserver.com       | 50                   | master3       |
| worker1       | 2   | 4096         | 10.17.4.24 | worker1.cefaslocalserver.com       | 50                   | worker1       |
| worker2       | 2   | 4096         | 10.17.4.25 | worker2.cefaslocalserver.com       | 50                   | worker2       |
| worker3       | 2   | 4096         | 10.17.4.26 | worker3.cefaslocalserver.com       | 50                   | worker3       |
| bootstrap     | 2   | 4096         | 10.17.4.27 | bootstrap.cefaslocalserver.com     | 50                   | bootstrap     |
| freeipa1      | 2   | 2048         | 10.17.3.11 | freeipa1.cefaslocalserver.com      | 32                   | freeipa1      |
| loadbalancer1 | 2   | 2048         | 10.17.3.12 | loadbalancer1.cefaslocalserver.com | 32                   | loadbalancer1 |
| postgresql1   | 2   | 2048         | 10.17.3.13 | postgresql1.cefaslocalserver.com   | 32                   | postgresql1   |
| helper        | 2   | 2048         | 10.17.3.14 | helper.cefaslocalserver.com        | 32                   | helper_node   |

## Máquinas Virtuales y Roles

| Nodo               | Sistema Operativo       | Función                                    | Cantidad |
| ------------------ | ----------------------- | ------------------------------------------ | -------- |
| Bastion Node       | Rocky Linux             | Acceso seguro y conexiones SSH al clúster  | 1        |
| Load Balancer Node | Rocky Linux             | Balanceo de tráfico con Traefik            | 1        |
| FreeIPA Node       | Rocky Linux             | DNS y autenticación                        | 1        |
| PostgreSQL Node    | Rocky Linux             | Base de datos central para microservicios  | 1        |
| Master Node        | Flatcar Container Linux | Administración de API de Kubernetes        | 3        |
| Worker Nodes       | Flatcar Container Linux | Ejecución de microservicios y aplicaciones | 3        |
| Bootstrap Node     | Flatcar Container Linux | Nodo inicial para configurar el clúster    | 1        |

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

## Fases de Implementación

### Fase 1: Instalación y Configuración de K3s en el Clúster de Kubernetes

1. **Nodo Bootstrap**: Instalación de K3s y configuración inicial del clúster.
2. **Nodos Master y Worker**: Configuración de nodos maestros y workers, desplegando Traefik como balanceador.

### Fase 2: Configuración de PostgreSQL

| Aspecto                 | Configuración                                                            |
| ----------------------- | ------------------------------------------------------------------------ |
| Servidor                | `postgresql1.cefaslocalserver.com`                                       |
| Permisos                | Ajusta permisos para permitir el acceso de microservicios en el clúster. |
| Respaldo y Recuperación | Define políticas para almacenamiento y recuperación de datos.            |

### Fase 3: Desarrollo e Implementación de Microservicios

- **Apache Kafka**: Canal de comunicación asíncrona entre microservicios.
- **MQTT Mosquitto**: Protocolo ligero para notificaciones en tiempo real.
- **Redis**: Base de datos en memoria para almacenamiento en caché y escalabilidad.

### Fase 4: Desarrollo del Frontend con Vue.js

- **Vue.js** para la interfaz de usuario, conectada a APIs de FastAPI. Desplegado en el clúster con acceso a través del balanceador Traefik.

## Automatización y Orquestación

- **Terraform**: Automatización de infraestructura.
- **Ansible**: Configuración y manejo de operaciones.

## Pasos para la Implementación

### Paso 1: Preparativos Iniciales

Clonar el repositorio en el servidor Rocky Linux.

#### Estructura del Proyecto

- `br0_network/`
- `nat_network_02/`
- `nat_network_03/`

#### Requisitos

- [Terraform](https://www.terraform.io/downloads.html) v0.13 o superior
- Acceso a un servidor KVM con libvirt

## Red y Conectividad

```bash
# Clonar repositorio
git clone https://github.com/vhgalvez/FlatcarMicroCloud.git
cd FlatcarMicroCloud
```

### Paso 2: Configuración de Redes Virtuales con Terraform

- **Red br0_network**:

  ```bash
  # Navegar a br0_network
  cd br0_network
  # Inicializar y aplicar Terraform
  sudo terraform init --upgrade
  sudo terraform apply
  ```

- **Red nat_network_02**:

  ```bash
  # Navegar a nat_network_02
  cd ../nat_network_02
  # Inicializar y aplicar Terraform
  sudo terraform init --upgrade
  sudo terraform apply
  ```

- **Red nat_network_03**:

  ```bash
  # Navegar a nat_network_03
  cd ../nat_network_03
  # Inicializar y aplicar Terraform
  sudo terraform init --upgrade
  sudo terraform apply
  ```

## Notas Adicionales

- Asegúrese de tener las variables y configuraciones adecuadas en los archivos `terraform.tfvars` de cada subproyecto.
- Cada subproyecto tiene su propio `main.tf` y configuración de variables, por lo que no debería haber conflictos de nombres si sigue las instrucciones anteriores.
- Puede ajustar las configuraciones y variables según sea necesario para adaptarse a su entorno y necesidades específicas.

### Paso 3: Instalación de VMs y Sistemas Operativos

Provisionar y configurar VMs según especificaciones en la tabla de recursos, asegurando la asignación de CPU, RAM, y almacenamiento.

### Paso 4: Configuración de Roles en las VMs

- **Master y Worker Nodes**:
  - Configurar K3s en los nodos Master.
  - Desplegar Traefik para el balanceo de carga.
- **FreeIPA Node**: Configurar para DNS y autenticación.
- **Load Balancer**: Configurar con Traefik para distribución de tráfico.
- **PostgreSQL Node**: Configurar permisos y definir políticas de respaldo.
- **Bootstrap Node**: Ejecutar las configuraciones iniciales del clúster.

### Paso 5: Configuración de Almacenamiento Persistente

Instalar y configurar Rook y Ceph en el clúster de Kubernetes para almacenamiento persistente.

### Paso 6: Configuración de Monitoreo y Visualización

- Configurar **Prometheus** y **Grafana** para monitoreo.
- Configurar **ELK Stack** para análisis de logs y visualización de datos.

### Paso 7: Configuración de CI/CD y Automatización

- Configurar **Jenkins**, **GitHub Actions** y **SonarQube** para integración continua.
- Configurar **Harbor**, **Docker Registry** y **Kaniko** para gestión de imágenes de contenedores.
- Configurar **ArgoCD** y **Spinnaker** para despliegue continuo.

### Paso 8: Configuración de Seguridad

Configurar reglas de **firewall**, **Fail2Ban** y políticas de seguridad con **FreeIPA**.

### Paso 9: Sincronización y NTP

Configurar **chronyc** en todos los nodos para sincronización temporal con **FreeIPA**.

### Paso 10: Pruebas Finales y Puesta en Producción

- Verificar configuración de red y DNS.
- Probar despliegue de aplicaciones y monitorización de métricas.
- Asegurar que el balanceador de carga y servicios en Kubernetes estén operativos.

Este flujo garantiza que todas las dependencias y configuraciones sean instaladas en el orden correcto y optimizadas para un entorno de producción.

## Microservicios en Pods

#### Análisis y Visualización de Datos

- **ELK Stack Elasticsearch**: Visualización de métricas del clúster.
- **ELK Stack Kibana**: Visualización de datos.
- **ELK Stack Logstash**: Procesamiento de logs.
- **Prometheus**: Herramientas para el monitoreo, alertas **alertmanager** y visualización de métricas.
- **Grafana**: Visualización de métricas del clúster.
- **cAdvisor**: Monitorear el rendimiento y uso de recursos por parte de los contenedores.
- **Nagios**: Rendimiento del sistema.

#### Microservicios de Servicios de Aplicaciones

- **Nginx**: Servidor web y proxy inverso para aplicaciones web.
- **Apache Kafka**: Plataforma de mensajería utilizada para la comunicación entre microservicios.
- **Redis**: Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.

## Seguridad y Protección

- **Firewall**: Configuración de reglas de firewall para proteger el clúster.
- **Fail2Ban**: Protección contra accesos no autorizados y ataques.
- **DNS y FreeIPA**: Gestión centralizada de autenticación y políticas de seguridad y servidor de DNS.

## Almacenamiento Persistente

- **Rook y Ceph**: Orquestar Ceph en Kubernetes para almacenamiento persistente.

## Kubernetes Operaciones

- **Kubernetes Operators**: Automatización de operaciones en Kubernetes.
- **Kubernetes Helm Charts**: Plantillas predefinidas para despliegues en Kubernetes.
- **Kubernetes Custom Resources**: Recursos personalizados para operaciones específicas en Kubernetes.
- **Kubernetes Ingress**: Gestión de tráfico de red en Kubernetes.
- **Kubernetes Services**: Exposición de servicios en Kubernetes.
- **Kubernetes Volumes**: Almacenamiento persistente en Kubernetes.
- **Kubernetes Namespaces**: Aislamiento de recursos en Kubernetes.
- **Kubernetes RBAC**: Control de acceso basado en roles en Kubernetes.
- **Kubernetes Secrets**: Gestión de secretos en Kubernetes.
- **Kubernetes ConfigMaps**: Gestión de configuraciones en Kubernetes.
- **Kubernetes Network Policies**: Políticas de red en Kubernetes.
- **Kubernetes Pod Security Policies**: Políticas de seguridad en Kubernetes.
- **Kubernetes Pod Disruption Budgets**: Control de la disponibilidad de pods en Kubernetes.
- **Kubernetes Horizontal Pod Autoscaler**: Escalado automático de pods en Kubernetes.
- **Kubernetes Vertical Pod Autoscaler**: Escalado automático de recursos en pods en Kubernetes.
- **Kubernetes Cluster Autoscaler**: Escalado automático de nodos en Kubernetes.
- **Kubernetes Pod Affinity**: Afinidad de pods en Kubernetes.
- **Kubernetes Pod Anti-Affinity**: Anti-afinidad de pods en Kubernetes.
- **Kubernetes Taints and Tolerations**: Tolerancias y restricciones en Kubernetes.
- **Kubernetes DaemonSets**: Despliegue de pods en todos los nodos en Kubernetes.
- **Kubernetes StatefulSets**: Despliegue de aplicaciones con estado en Kubernetes.
- **Kubernetes Jobs**: Ejecución de tareas en Kubernetes.

## Seguridad y Monitoreo

- **FreeIPA**: DNS y gestión de autenticación.
- **Prometheus y Grafana**: Monitoreo avanzado y visualización de métricas.
- **Rook y Ceph**: Almacenamiento persistente en Kubernetes.
- **Firewall y Fail2Ban**: Seguridad del entorno.

## Redes Virtuales y Arquitectura de Red

### Redes Virtuales Configuradas

| Red NAT         | Nodos         | Dirección IP | Rol del Nodo                             |
| --------------- | ------------- | ------------ | ---------------------------------------- |
| kube_network_02 | freeipa1      | 10.17.3.11   | Servidor de DNS y gestión de identidades |
| kube_network_02 | loadbalancer1 | 10.17.3.12   | Balanceo de carga para el clúster        |
| kube_network_02 | postgresql1   | 10.17.3.13   | Gestión de bases de datos                |
| kube_network_02 | bootstrap1    | 10.17.3.14   | Inicialización del clúster               |
| kube_network_03 | master1       | 10.17.4.21   | Gestión del clúster                      |
| kube_network_03 | worker1       | 10.17.4.24   | Ejecución de aplicaciones                |
| kube_network_03 | worker2       | 10.17.4.25   | Ejecución de aplicaciones                |
| kube_network_03 | worker3       | 10.17.4.26   | Ejecución de aplicaciones                |

### Red br0 - Bridge Network

| Red NAT | Nodo     | Dirección IP | Rol del Nodo                               |
| ------- | -------- | ------------ | ------------------------------------------ |
| br0     | bastion1 | 192.168.0.20 | Acceso seguro, Punto de conexión de bridge |

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

## Configuración de Redes Virtuales

### Red br0 - Bridge Network

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
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

## Configuración de Redes Virtuales

- **Switch**: TP-Link LS1008G - 8 puertos Gigabit no administrados
- **Router WiFi**: Conexión fibra óptica, 600 Mbps de subida/bajada, IP pública
- **Red**: Configurada red NAT y red Bridge de kvm
- **VPN**: WireGuard para acceso seguro SSH administrado por Bastion Node

## FreeIPA (10.17.3.11)

- **Servidor DNS y NTP (chronyc)**:
  FreeIPA actúa como el servidor DNS, gestionando la resolución de nombres y autenticación dentro del clúster. Además, **chronyc** está configurado para sincronizar el tiempo en todo el clúster, utilizando FreeIPA como uno de los servidores NTP principales.

## Chronyc / NTP

- **Sincronización de tiempo**:
  FreeIPA también proporciona servicios NTP. Todos los nodos del clúster, incluyendo los nodos maestros, workers y el Bootstrap Node, sincronizan su tiempo utilizando **chronyc** y el servidor NTP de FreeIPA (`10.17.3.11`). Esto garantiza que todos los nodos mantengan una sincronización temporal precisa, lo cual es crucial para la operación correcta de Kubernetes y otros servicios distribuidos.

---

## Diagramas de Red y Arquitectura

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

![alt text](additional_resources/image/nodos_mv.png)

## Optimización para Producción

| Aspecto                     | Detalle                                                                                            |
| --------------------------- | -------------------------------------------------------------------------------------------------- |
| Restricción de Recursos     | Configura límites en Kubernetes para cada servicio (Prometheus, PostgreSQL, Kafka, Redis).         |
| Control de Logs y Monitoreo | Define políticas de retención de logs en Prometheus y Kafka para reducir el consumo de disco.      |
| Supervisión Activa          | Usa Grafana para monitoreo en tiempo real, ajustando recursos según los picos de carga detectados. |

Estas optimizaciones aseguran un entorno escalable y eficiente para producción.

## Interfaz de Red

| Interfaz     |
| ------------ |
| **enp3s0f0** |
| **enp3s0f1** |
| **enp4s0f0** |
| **enp4s0f1** |
| **lo**       |

Estas interfaces están conectadas a un switch y un router de fibra óptica, operando bajo DHCP y facilitando la conectividad y administración del clúster.

## Resumen del Flujo

1. **Ingreso de Conexiones Externas**: Las conexiones HTTPS externas ingresan por la **IP pública (192.168.0.21)**.
2. **Acceso Seguro**: El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. **Distribución de Tráfico**: El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. **Instalación de OKD**: El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al **FreeIPA**.
5. **Resolución de Nombres y Sincronización de Tiempo**:
   - **FreeIPA** actúa como servidor DNS y NTP, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. **Ejecución de Aplicaciones**: Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con **FreeIPA** a través de **chronyc**.

