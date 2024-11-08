# FlatcarMicroCloud: Entorno Kubernetes Optimizado para Servidores Físicos con Comunicación de Microservicios y Escalabilidad

## Descripción General

FlatcarMicroCloud es una solución Kubernetes diseñada para maximizar los recursos de un servidor físico, en este caso, el ProLiant DL380 G7 ejecutando Rocky Linux 9.4. FlatcarMicroCloud facilita el despliegue de aplicaciones en contenedores con herramientas como K3s para Kubernetes ligero, Rook y Ceph para almacenamiento persistente, y monitoreo avanzado con Prometheus y Grafana. Este entorno optimizado permite una administración eficiente y escalabilidad. Ahora incluye comunicación entre microservicios con Apache Kafka y MQTT Mosquitto, y Redis para escalabilidad de base de datos en RAM.

---

## Análisis de Recursos

| Recurso              | Descripción                                                                                                               |
|----------------------|---------------------------------------------------------------------------------------------------------------------------|
| **CPU**              | Intel Xeon X5650 (24 hilos a 2.666 GHz). Adecuado para manejar cargas de Kubernetes, FastAPI, Redis, Kafka y Mosquitto.   |
| **Memoria RAM**      | 35 GB de RAM, suficiente para el clúster y servicios de escalabilidad como Redis y almacenamiento de mensajes en Kafka.   |
| **Almacenamiento I/O** | Almacenamiento confiable para PostgreSQL, Kafka y logs. Ceph facilita el almacenamiento distribuido y Rook asegura la persistencia. |

### Optimización para Producción

| Aspecto                       | Detalle                                                                                                           |
|-------------------------------|--------------------------------------------------------------------------------------------------------------------|
| **Restricción de Recursos**   | Configura límites en Kubernetes para cada servicio (Prometheus, PostgreSQL, Jenkins, Kafka, Redis).               |
| **Control de Logs y Monitoreo** | Define políticas de retención de logs en Prometheus y Kafka para reducir el consumo de disco.                     |
| **Supervisión Activa**        | Usa Grafana para monitoreo en tiempo real, ajustando recursos según los picos de carga detectados.                |

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

- **Servidor DNS y NTP (chronyc)**: FreeIPA actúa como el servidor DNS, gestionando la resolución de nombres y autenticación dentro del clúster. Además, **chronyc** está configurado para sincronizar el tiempo en todo el clúster, utilizando FreeIPA como uno de los servidores NTP principales.

---

## Chronyc / NTP

- **Sincronización de tiempo**: FreeIPA proporciona servicios NTP. Todos los nodos del clúster, incluyendo los nodos maestros, workers y el Bootstrap Node, sincronizan su tiempo utilizando **chronyc** y el servidor NTP de FreeIPA (`10.17.3.11`). Esto garantiza que todos los nodos mantengan una sincronización temporal precisa, esencial para la operación correcta de Kubernetes y otros servicios distribuidos.

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

## Resumen de los Hostnames e IPs

| Dirección IP  | Hostname                        |
|---------------|---------------------------------|
| 10.17.3.11    | freeipa1.cefaslocalserver.com   |
| 10.17.3.12    | load_balancer1.cefaslocalserver.com |
| 10.17.3.13    | postgresql1.cefaslocalserver.com |
| 10.17.4.21    | master1.cefaslocalserver.com    |
| 10.17.4.24    | worker1.cefaslocalserver.com    |
| 10.17.4.25    | worker2.cefaslocalserver.com    |
| 10.17.4.26    | worker3.cefaslocalserver.com    |

---

## Automatización y Orquestación

- **Terraform**: Automatización de infraestructura
- **Ansible**: Configuración y manejo de operaciones

### Microservicios en pods

#### Análisis y Visualización de Datos

- **ELK Stack Elasticsearch**: Visualización de métricas del clúster
- **ELK Stack Kibana**: Visualización de datos
- **ELK Stack Logstash**: Procesamiento de logs
- **Prometheus**: Herramientas para el monitoreo , alertas **alertmanager** y visualización de métricas
- **Grafana**: Visualización de métricas del clúster
- **cAdvisor**: Monitoreo del rendimiento y uso de recursos por parte de los contenedores.
- **Nagios**: Rendimiento del sistema

#### Microservicios de Aplicaciones

- **Nginx**: Servidor web y proxy inverso para aplicaciones web.
- **Apache Kafka**: Plataforma de mensajería para la comunicación entre microservicios.
- **Redis**: Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.

### Seguridad y Protección

- **Firewall**: Configuración de reglas de firewall para proteger el clúster.
- **Fail2Ban**: Protección contra accesos no autorizados y ataques.
- **DNS y FreeIPA**: Gestión centralizada de autenticación y políticas de seguridad, además de servir como DNS.

### Almacenamiento Persistente

- **Rook y Ceph**: Rook orquesta Ceph en Kubernetes para almacenamiento persistente.

### Integración continua CI/CD

- **Jenkins**: Automatización de pruebas y despliegue de aplicaciones.
- **GitHub Actions**: Control de versiones y CI/CD.
- **SonarQube**: Análisis de código y calidad.
- **Docker Registry**: Registro de imágenes de contenedores.
- **Harbor**: Registro de imágenes de contenedores y escaneo de vulnerabilidades.
- **Kaniko**: Construcción de imágenes de contenedores sin privilegios.
- **Helm**: Gestión de paquetes de Kubernetes.
- **Kustomize**: Personalización de despliegues de Kubernetes.
- **ArgoCD**: Despliegue continuo de aplicaciones en Kubernetes.
- **Tekton**: Automatización de pipelines de CI/CD.
- **Spinnaker**: Automatización de despliegues en Kubernetes.


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

---

## Configuración de Redes Virtuales

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}

resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}

resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
```


## Diagrama de Arquitectura

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

# Resumen del Flujo

1. **Ingreso de Conexiones Externas**: Las conexiones HTTPS externas ingresan por la **IP pública (192.168.0.21)**.
2. **Acceso Seguro**: El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. **Distribución de Tráfico**: El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. **Instalación de OKD**: El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al **FreeIPA**.
5. **Resolución de Nombres y Sincronización de Tiempo**:
   - **FreeIPA** actúa como servidor DNS y NTP, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. **Ejecución de Aplicaciones**: Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con **FreeIPA** a travé
