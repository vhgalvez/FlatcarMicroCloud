# FlatcarMicroCloud: Entorno Kubernetes Optimizado para Servidores Físicos

## 1. Descripción General del Proyecto

**FlatcarMicroCloud** es una solución Kubernetes diseñada para maximizar los recursos de un servidor físico. El entorno se ejecuta sobre un servidor **ProLiant DL380 G7**, utilizando **Rocky Linux 9.5** como sistema operativo base para virtualización, junto con **AlmaLinux 9.4** en algunos nodos auxiliares. Las máquinas virtuales que componen el clúster Kubernetes utilizan **Flatcar Container Linux** como sistema operativo liviano y seguro.

Esta arquitectura permite desplegar aplicaciones en contenedores mediante herramientas modernas como:

- **K3s**, una distribución ligera de Kubernetes.
- **Longhorn y NFS** para almacenamiento persistente.
- **Prometheus y Grafana** para monitoreo y visualización avanzada.
- **Redpanda y MQTT Mosquitto** para comunicación asincrónica entre microservicios.

### 🧱 Prerrequisitos del Proyecto

#### 📦 Sistemas Operativos Compatibles

- **Rocky Linux 9.5**: Sistema base para nodos de administración y servicios core.
- **Flatcar Container Linux (versión estable actual)**: Sistema inmutable optimizado para contenedores, ideal para nodos worker y cargas K3s.
- **AlmaLinux 9.4**: Alternativa empresarial compatible con RHEL para nodos de infraestructura como balanceadores de carga o almacenamiento.

#### ⚙️ Virtualización y Automatización

##### Hipervisor

- **KVM/QEMU**: Virtualización nativa de alto rendimiento para entornos Linux.
- **Virt-Manager** _(opcional)_: Interfaz gráfica para la gestión de máquinas virtuales.

##### Provisión de Infraestructura

- **Libvirt** como backend de virtualización.
- **Terraform** con el proveedor `libvirt`: Automatización del ciclo de vida de las máquinas virtuales.

## 2. Hardware del Servidor

- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI ES1000
- **Memoria Total**: 35 GB RAM
- **Almacenamiento**:
  - Disco Principal: 1.5TB
  - Disco Secundario: 3.0TB

### Homelab Server (Servidor Físico ProLiant DL380 G7)

![ProLiant DL380 G7](additional_resources/image/hp_server.png)

![Virtualizacion KVM](additional_resources/image/virtualizacion_kvm.jpg)

![Servidor en Rack](additional_resources/image/servidor_rack_01.jpg)

![Servidor en Rack](additional_resources/image/servidor_rack_02.jpg)

## 3. Sistemas Operativos y Virtualización

- **Sistemas Operativos**: Rocky Linux 9.5, Flatcar Container Linux y Alma Linux 9.4
- **Virtualización**: KVM con Libvirt y Virt-Manager
- **Configuración de Red**: VPN con WireGuard, DHCP, firewall, y configuraciones de redes virtuales (NAT y Bridge) con KVM.
- **Switch y Router**: Facilitan la comunicación y conectividad del clúster.

## 4. Resumen de Recursos para Máquinas Virtuales

| **Hostname**  | **IP**       | **Dominio**                        | **CPU** | **Memoria (MB)** | **Disco (GB)** |
| ------------- | ------------ | ---------------------------------- | ------- | ---------------- | -------------- |
| master1       | 10.17.4.21   | master1.cefaslocalserver.com       | 2       | 4096             | 50             |
| master2       | 10.17.4.22   | master2.cefaslocalserver.com       | 2       | 4096             | 50             |
| master3       | 10.17.4.23   | master3.cefaslocalserver.com       | 2       | 4096             | 50             |
| worker1       | 10.17.4.24   | worker1.cefaslocalserver.com       | 2       | 4096             | 50             |
| worker2       | 10.17.4.25   | worker2.cefaslocalserver.com       | 2       | 4096             | 50             |
| worker3       | 10.17.4.26   | worker3.cefaslocalserver.com       | 2       | 4096             | 50             |
| storage1      | 10.17.3.27   | storage1.cefaslocalserver.com      | 2       | 2048             | 80             |
| infra-cluster | 10.17.3.11   | infra-cluster.cefaslocalserver.com | 2       | 2048             | 32             |
| loadbalancer1 | 10.17.3.12   | loadbalancer1.cefaslocalserver.com | 2       | 2048             | 32             |
| loadbalancer2 | 10.17.3.13   | loadbalancer2.cefaslocalserver.com | 2       | 2048             | 32             |
| postgresql1   | 10.17.3.14   | postgresql1.cefaslocalserver.com   | 2       | 2048             | 32             |
| k8s-api-lb    | 192.168.0.30 | k8s-api-lb.cefaslocalserver.com    | 2       | 2048             | 80             |

## 5. Máquinas Virtuales y Roles

| Nodo               | Sistema Operativo       | Función                                    | Cantidad |
| ------------------ | ----------------------- | ------------------------------------------ | -------- |
| k8s-api-lb         | Alma Linux              | Gestión y seguridad                        | 1        |
| Load Balancer Node | Alma Linux              | Balanceo Traefik controlador de ingress    | 2        |
| infra-cluster Node | Alma Linux              | DNS CoreDNS / NTP Chrony                   | 1        |
| PostgreSQL Node    | Alma Linux              | Base de datos central para microservicios  | 1        |
| Master Node        | Flatcar Container Linux | Administración de API de Kubernetes        | 3        |
| Worker Nodes       | Flatcar Container Linux | Ejecución de microservicios y aplicaciones | 3        |
| storage1           | Alma Linux              | Almacenamiento                             | 1        |

## 6. Explicación de Roles de las VMs

- **Maestros (master1, master2, master3)**:

  - Nodos que conforman el plano de control de Kubernetes, manejando la API y distribuyendo la carga en los nodos worker.

- **Workers (worker1, worker2, worker3)**:

  - Nodos que ejecutan aplicaciones y microservicios, proporcionando la capacidad de escalar horizontalmente.

- **infra-cluster (infra-cluster)**:

  - Nodo que actúa como servidor DNS CoreDNS y NTP Chrony.

- **Load Balancer (loadbalancer1, loadbalancer2)**:

  - Nodos que distribuyen el tráfico de red entre los nodos maestros y workers, asegurando un balanceo de carga eficiente.

- **PostgreSQL (postgresql1)**:
  - Nodo dedicado para la base de datos, proporcionando almacenamiento persistente para las aplicaciones de microservicios.

## 7. Fases de Implementación

### 7.1 Instalación y Configuración de K3s en el Clúster de Kubernetes

1. **Nodo Master1**: Instalación de K3s y configuración inicial del clúster.
2. **Nodos Master y Worker**: Configuración de nodos maestros y workers, desplegando Traefik como balanceador.

### 7.2 Configuración de PostgreSQL

| Aspecto                 | Configuración                                                            |
| ----------------------- | ------------------------------------------------------------------------ |
| Servidor                | `postgresql1.cefaslocalserver.com`                                       |
| Permisos                | Ajusta permisos para permitir el acceso de microservicios en el clúster. |
| Respaldo y Recuperación | Define políticas para almacenamiento y recuperación de datos.            |

### 7.3 Desarrollo e Implementación de Microservicios

- **Redpanda**: Canal de comunicación asíncrona entre microservicios.
- **MQTT Mosquitto**: Protocolo ligero para notificaciones en tiempo real.
- **Redis**: Base de datos en memoria para almacenamiento en caché y escalabilidad.

### 7.4 Desarrollo del Frontend con Vue.js

- **Vue.js** para la interfaz de usuario, conectada a APIs de FastAPI. Desplegado en el clúster con acceso a través del balanceador Traefik.

## 8. Automatización y Orquestación

- **Terraform**: Automatización de infraestructura.
- **Ansible**: Configuración y manejo de operaciones.

## 9. Pasos para la Implementación

### 9.1 Preparativos Iniciales

Clonar el repositorio en el servidor Rocky Linux.

#### Estructura del Proyecto

- `nat_network_01/`
- `nat_network_02/`
- `nat_network_03/`

#### Requisitos

- [Terraform](https://www.terraform.io/downloads.html) v0.13 o superior
- Acceso a un servidor KVM con libvirt

### 9.2 Configuración de Redes Virtuales con Terraform

- **Red nat_network_01**:

  ```bash
  cd nat_network_01
  sudo terraform init --upgrade
  sudo terraform apply
  ```

- **Red nat_network_02**:

  ```bash
  cd ../nat_network_02
  sudo terraform init --upgrade
  sudo terraform apply
  ```

- **Red nat_network_03**:

  ```bash
  cd ../nat_network_03
  sudo terraform init --upgrade
  sudo terraform apply
  ```

### 9.3 Instalación de VMs y Sistemas Operativos

Provisionar y configurar VMs según especificaciones en la tabla de recursos, asegurando la asignación de CPU, RAM, y almacenamiento.

### 9.4 Configuración de Almacenamiento Persistente

Instalar y configurar Longhorn y NFS en el clúster de Kubernetes para almacenamiento persistente.

### 9.5 Configuración de Monitoreo y Visualización

- Configurar **Prometheus** y **Grafana** para monitoreo.
- Configurar **ELK Stack** para análisis de logs y visualización de datos.

### 9.6 Configuración de CI/CD y Automatización

Configurar Jenkins y/o GitHub Actions para la integración continua (CI), ejecutando pruebas automáticas, análisis de código y construcción de imágenes de contenedor.

Configurar un Docker Registry (privado o público) para almacenar y versionar imágenes generadas por el proceso de CI.

Configurar ArgoCD como herramienta de despliegue continuo (CD), conectando los cambios en el repositorio con el entorno de Kubernetes mediante una estrategia GitOps.

### 9.7 Configuración de Seguridad

Configurar reglas de **firewall**, **Fail2Ban** y políticas de seguridad.

### 9.8 Sincronización y NTP

Configurar **chronyc** en todos los nodos para sincronización temporal.

### 9.9 Pruebas Finales y Puesta en Producción

- Verificar configuración de red y DNS.
- Probar despliegue de aplicaciones y monitorización de métricas.
- Asegurar que el balanceador de carga y servicios en Kubernetes estén operativos.

---

Siguiendo este flujo, todas las dependencias y configuraciones serán instaladas en el orden correcto y optimizadas para un entorno de producción.

## Microservicios en Pods

### Servicios de Aplicaciones

- **Nginx**: Servidor web para aplicaciones.
- **Redis**: Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.
- **Kafka**: Plataforma de mensajería utilizada para la comunicación entre microservicios.

### Análisis y Visualización de Datos

- **Prometheus**: Herramientas para el monitoreo y alertas.
- **Grafana**: Visualización de métricas del clúster.
- **Nagios**: Monitoreo del rendimiento del sistema.
- **cAdvisor**: Monitoreo del rendimiento y uso de recursos por parte de los contenedores.
- **ELK Stack**: Procesamiento y visualización de logs.

## Seguridad y Protección

- **Firewall nftables**: Configuración de reglas de firewall para proteger el clúster.
- **Fail2Ban**: Protección contra accesos no autorizados y ataques.

## Almacenamiento Persistente

- **Longhorn**: Orquestar Longhorn en Kubernetes para almacenamiento persistente.
- **NFS**: Configurar NFS para almacenamiento compartido entre nodos para base de datos postgresql.

## Chronyc / NTP

- **Sincronización de tiempo**:
  Todos los nodos del clúster, incluyendo los nodos maestros, workers y el Bootstrap Node, sincronizan su tiempo utilizando **chronyc**. Esto garantiza que todos los nodos mantengan una sincronización temporal precisa, lo cual es crucial para la operación correcta de Kubernetes y otros servicios distribuidos.

## Redes Virtuales y Arquitectura de Red

### Redes Virtuales Configuradas

| Red NAT         | Nodos         | Dirección IP | Rol del Nodo                             |
| --------------- | ------------- | ------------ | ---------------------------------------- |
| kube_network_02 | infra-cluster | 10.17.3.11   | Servidor de DNS y gestión de identidades |
| kube_network_02 | loadbalancer1 | 10.17.3.12   | Balanceo de carga para el clúster        |
| kube_network_02 | loadbalancer2 | 10.17.3.13   | Balanceo de carga para el clúster        |
| kube_network_02 | postgresql1   | 10.17.3.14   | Gestión de bases de datos                |
| kube_network_03 | master1       | 10.17.4.21   | Gestión del clúster                      |
| kube_network_03 | master2       | 10.17.4.22   | Gestión del clúster                      |
| kube_network_03 | master3       | 10.17.4.23   | Gestión del clúster                      |
| kube_network_03 | worker1       | 10.17.4.24   | Ejecución de aplicaciones                |
| kube_network_03 | worker2       | 10.17.4.25   | Ejecución de aplicaciones                |
| kube_network_03 | worker3       | 10.17.4.26   | Ejecución de aplicaciones                |
| kube_network_03 | storage1      | 10.17.4.27   | Almacenamiento                           |

### Red nat_network_01

| Red NAT         | Nodo       | Dirección IP | Rol del Nodo             |
| --------------- | ---------- | ------------ | ------------------------ |
| kube_network_01 | k8s-api-lb | 10.17.5.10   | HAProxy + Keepalived VIP |

## Detalles de Configuración

- **Imágenes Base**:

  - Fedora CoreOS: `/mnt/lv_data/organized_storage/images/fedora-coreos-40.20240906.3.0-qemu.x86_64.qcow2`
  - Rocky Linux: `/mnt/lv_data/organized_storage/images/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2`
  - Alma Linux: `/mnt/lv_data/organized_storage/images/AlmaLinux-9.4-x86_64.qcow2`
  - pfsense: `/mnt/lv_data/organized_storage/images/pfsense_base.qcow2`
  - Flatcar Container Linux: `/mnt/lv_data/organized_storage/images/flatcar_production_qemu_image.img`

- **Red Gateway**:

  - kube_network_01: 10.17.5.1
  - kube_network_02: 10.17.3.1
  - kube_network_03: 10.17.4.1

- **DNS**:

  - Primario: 10.17.3.11 (infra-cluster)
  - Secundario: 8.8.8.8

- **Zona Horaria**:

  - Europe/London

- **Clave SSH**:

  - Clave pública SSH incluida para acceso seguro a las VMs.

## Configuración de Redes Virtuales

### Red nat_network_01

```hcl
resource "libvirt_network" "Kube_network_01" {
  name      = var.rocky9_network_name
  mode      = "nat"
  autostart = true
  addresses = ["10.17.5.0/24"]
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

## Interfaz de Red

| Interfaz     |
| ------------ |
| **enp3s0f0** |
| **enp3s0f1** |
| **enp4s0f0** |
| **enp4s0f1** |
| **lo**       |

Estas interfaces están conectadas a un switch y un router de fibra óptica, operando bajo DHCP y facilitando la conectividad y administración del clúster.

## Arquitectura de Red (Router fibra optica y Switch TP-Link LS1008G)

![Switch TP-Link LS1008G](additional_resources/image/switch-tplink-ls1008g.jpg)

1. **Distribución de Tráfico**:

   - Los Load Balancers (Traefik) distribuyen el tráfico hacia los nodos maestros y workers, asegurando un balanceo eficiente.

2. **Resolución de Nombres y Sincronización de Tiempo**:

   - El nodo `infra-cluster` actúa como servidor DNS y NTP, garantizando la resolución de nombres y la sincronización temporal en todo el clúster.

3. **Ejecución de Aplicaciones**:

   - Los nodos workers y maestros ejecutan las aplicaciones, manteniendo la sincronización temporal a través de `chronyc`.

# 🔁 Proceso Modular de Automatización — Clúster K3s HA (bare-metal)

|  Nº | Fase | Proyecto / Repositorio             | Motivo principal               | Dependencias clave            |
| --: | :--: | ---------------------------------- | ------------------------------ | ----------------------------- |
|   1 |  0   | [generate_shared_ssh_key]          | SSH sin contraseña entre nodos | —                             |
|   2 |  0   | [kvm-bridge-config]                | Bridge LAN real a las VMs      | 1                             |
|   3 |  1   | [ansible-CoreDNS-setup-Linux]      | DNS interno                    | 1-2                           |
|   4 |  1   | [ansible-ntp-chrony-kubernetes]    | Sincronización de tiempo       | 1-2                           |
|   5 |  2   | [ansible-k8s-ha-loadbalancer]      | VIPs con HAProxy + Keepalived  | 3-4                           |
|   6 |  3   | [ansible-k3s-etcd-cluster]         | K3s HA (etcd)                  | 5                             |
|   7 |  4   | [k3s-vip-switch-master1-bootstrap] | Re-alinea `master-0` a la VIP  | 6                             |
|   8 |  5   | [ansible-k3s-configure-access]     | Copia `kubeconfig` remoto      | 6-7                           |
|   9 |  6   | [flatcar-k3s-storage-suite]        | Longhorn + NFS (PVC)           | 6                             |
|  10 |  7   | [traefik-ansible-k3s-cluster]      | Ingress Controller + TLSStore  | 9                             |
|  11 |  7   | [longhorn-dashboard-ui-ansible]    | UI protegida de Longhorn       | 9-10                          |
|  12 |  8   | [ansible-SealedSecrets-kubeseal]   | Secretos cifrados (GitOps)     | 6                             |
|  13 |  9   | [ArgoCD-ansible-kubernetes]        | Motor GitOps                   | 10-12                         |
|  14 |  10  | [jenkins-ansible-playbook]         | CI/CD (build → push → ArgoCD)  | 10-13                         |
|  15 |  10  | [ansible-monitoring-stack]         | Prometheus + Grafana           | 9-10                          |
|  16 |  11  | [postgres-ansible-nfs]             | PostgreSQL stateful            | 9-15                          |
|  17 |  12  | [cloudflare-dynamic-dns]           | DDNS Cloudflare                | opcional — antes de emitir LE |

> **Leyenda de fases**  
> 0 Bootstrap host-to-host 1 Servicios base 2 VIP network  
> 3 Control-plane 4 VIP switch 5 Acceso remoto  
> 6 Persistencia 7 Ingress & UI 8 Sealed Secrets  
> 9 GitOps engine 10 Workloads críticos 11 Base de datos  
> 12 Servicios auxiliares

---

# 🔁 Proceso Modular de Automatización para Clúster K3s HA (Bare-Metal)

|  Nº | Proyecto / Repositorio                                                                           | Motivo principal               | Notas de dependencia                              |
| --: | ------------------------------------------------------------------------------------------------ | ------------------------------ | ------------------------------------------------- |
|   1 | [generate_shared_ssh_key](https://github.com/vhgalvez/generate_shared_ssh_key)                   | SSH sin contraseña entre nodos | Requisito para todos los playbooks posteriores    |
|   2 | [kvm-bridge-config](https://github.com/vhgalvez/kvm-bridge-config)                               | Bridge LAN real a las VMs      | Reinicia libvirt/networks                         |
|   3 | [ansible-CoreDNS-setup-Linux](https://github.com/vhgalvez/ansible-CoreDNS-setup-Linux)           | DNS interno                    | Clúster y etcd dependen de DNS local              |
|   4 | [ansible-ntp-chrony-kubernetes](https://github.com/vhgalvez/ansible-ntp-chrony-kubernetes)       | Sincronización de tiempo       | Necesario para certificados y etcd                |
|   5 | [ansible-k3s-ha-loadbalancer](https://github.com/vhgalvez/ansible-k3s-ha-loadbalancer)           | VIPs con HAProxy + Keepalived  | Expone 6443/80/443                                |
|   6 | [ansible-k3s-etcd-cluster](https://github.com/vhgalvez/ansible-k3s-etcd-cluster)                 | K3s HA con etcd                | Usa la VIP como `--tls-san`                       |
|   7 | [k3s-vip-switch-master1-bootstrap](https://github.com/vhgalvez/k3s-vip-switch-master1-bootstrap) | Re-alinea master-0 a la VIP    | Solo si bootstrap inicial fue con la IP local     |
|   8 | [ansible-k3s-configure-access](https://github.com/vhgalvez/ansible-k3s-configure-access)         | Copia `kubeconfig` remoto      | Para gestionar el clúster desde tu estación       |
|   9 | [flatcar-k3s-storage-suite](https://github.com/vhgalvez/flatcar-k3s-storage-suite)               | Longhorn + NFS (PVC)           | Provee almacenamiento persistente                 |
|  10 | [traefik-ansible-k3s-cluster](https://github.com/vhgalvez/traefik-ansible-k3s-cluster)           | Ingress Controller + TLSStore  | Consume PVC Longhorn (`acme.json`)                |
|  11 | [longhorn-dashboard-ui-ansible](https://github.com/vhgalvez/longhorn-dashboard-ui-ansible)       | UI protegida de Longhorn       | Publicada vía Traefik                             |
|  12 | [ansible-SealedSecrets-kubeseal](https://github.com/vhgalvez/ansible-SealedSecrets-kubeseal)     | Secretos cifrados para GitOps  | Requiere API K3s operativa                        |
|  13 | [ArgoCD-ansible-kubernetes](https://github.com/vhgalvez/ArgoCD-ansible-kubernetes)               | Motor GitOps                   | Depende de Traefik, Sealed Secrets y PVC          |
|  14 | [jenkins-ansible-playbook](https://github.com/vhgalvez/jenkins-ansible-playbook)                 | CI/CD (build → push → ArgoCD)  | Publicado vía Traefik y gestionado por ArgoCD     |
|  15 | [ansible-monitoring-stack](https://github.com/vhgalvez/ansible-monitoring-stack)                 | Prometheus + Grafana           | Usa PVC y se expone por Traefik                   |
|  16 | [postgres-ansible-nfs](https://github.com/vhgalvez/postgres-ansible-nfs)                         | PostgreSQL stateful            | PVC Longhorn; métricas ya disponibles             |
|  17 | [cloudflare-dynamic-dns](https://github.com/vhgalvez/cloudflare-dynamic-dns)                     | DDNS público en Cloudflare     | Opcional; ejecútalo antes de emitir Let’s Encrypt |

---

# 🌐 Ecosistema DevOps: Entorno Local (K3d) y Producción (K3s)

Este repositorio forma parte de un ecosistema completo de **laboratorio DevOps en Kubernetes**, diseñado para simular entornos reales con herramientas modernas y de bajo coste. Ideal para validar flujos CI/CD, GitOps y despliegue automatizado en entornos locales (K3d) y escalables a producción (K3s).

---

## 🧹 Repositorios del ecosistema

| Proyecto                                                                                                 | Descripción                                                                                                                                 |
| -------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| [socialdevs-gitops](https://github.com/vhgalvez/socialdevs-gitops)                                       | Repositorio GitOps gestionado por ArgoCD. Contiene los manifiestos de las aplicaciones desplegadas automáticamente en Kubernetes.           |
| [Jenkins\_k3d\_local](https://github.com/vhgalvez/Jenkins_k3d_local)                                     | Instalación automatizada de Jenkins en K3d usando Helm y JCasC. Incluye agentes Kubernetes (Node.js, Kaniko) y pipelines CI/CD funcionales. |
| [argocd-bootstrap\_local\_k3d](https://github.com/vhgalvez/argocd-bootstrap_local_k3d)                   | Instalación de ArgoCD en entorno local con Helm. Incluye ejemplo de bootstrap para sincronizar aplicaciones desde el repositorio GitOps.    |
| [socialdevs-public-frontend](https://github.com/vhgalvez/socialdevs-public-frontend)                     | Aplicación frontend (Vue.js) conectada al pipeline CI/CD (Jenkins) y desplegada con GitOps (ArgoCD).                                        |
| [frontend-socialdevs-argocd-bootstrap](https://github.com/vhgalvez/frontend-socialdevs-argocd-bootstrap) | Configuración específica para bootstrap de la app frontend en ArgoCD. Ú til en la inicialización del entorno GitOps.                        |

---

## 🧪 Entorno local (K3d)

* Cluster local de Kubernetes con [K3d](https://k3d.io/)
* Jenkins con JCasC, agentes Kaniko/Node.js, CI funcional
* ArgoCD con sincronización automática desde repositorio GitOps
* Traefik como Ingress Controller con TLS local (autofirmado o mkcert)
* Perfecto para desarrollo, testing y aprendizaje DevOps

---

## 🚀 Producción (K3s)

* Cluster Kubernetes ligero y productivo con [K3s](https://k3s.io/)
* Helm + ArgoCD para despliegue GitOps continuo
* TLS con Let's Encrypt + almacenamiento persistente (Longhorn/NFS)
* Compatible con el mismo flujo y manifiestos que K3d
* Fácil de desplegar en cloud, bare-metal o datacenter low-cost

---

## 🔁 Flujo CI/CD (Jenkins + ArgoCD + GitOps)

```mermaid
graph TD
  A[Commit en GitHub] --> B[Jenkins CI]
  B --> C[DockerHub (build + push)]
  B --> D[Actualiza manifiestos YAML]
  D --> E[Repositorio GitOps (socialdevs-gitops)]
  E --> F[ArgoCD CD]
  F --> G[Cluster K3d o K3s]
```

## 📦 Tecnologías clave

* **Kubernetes** (K3d local / K3s producción)
* **Jenkins** (CI + JCasC + Agentes personalizados)
* **ArgoCD** (GitOps)
* **DockerHub** (Imágenes públicas)
* **Vue.js** (Frontend app)
* **Helm** (Paquetes y despliegues)
* **Traefik** (Ingress + TLS)
* **Longhorn** (Persistencia opcional en producción)

## 📁 Estructura general

```
📆 socialdevs-gitops
📆 Jenkins_k3d_local
📆 argocd-bootstrap_local_k3d
📆 socialdevs-public-frontend
📆 frontend-socialdevs-argocd-bootstrap
```

## ✅ Objetivo

Proveer una base sólida y funcional para:

* Simular entornos reales DevOps desde el entorno local
* Aprender y practicar CI/CD y GitOps
* Escalar sin fricción hacia producción en K3s o entornos cloud

---

| Proyecto                                         | Repositorio                                                                                                                              |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Traefik Ingress Controller external _(opcional)_ | [https://github.com/vhgalvez/traefik-ansible-external-k3s-ingress](https://github.com/vhgalvez/traefik-ansible-external-k3s-ingress.git) |

## Arquitectura de Infraestructura Global de FlatcarMicroCloud

![Infraestructura Global](additional_resources/image/infraestructura_global.png)

**Repositorio:** [arquitectura_FlatcarMicroCloud](https://github.com/vhgalvez/arquitectura_FlatcarMicroCloud) - https://github.com/vhgalvez/arquitectura_FlatcarMicroCloud

Este diagrama fue generado con **Python** utilizando la librería [Diagrams by Mingrammer](https://github.com/mingrammer/diagrams).  
Representa la arquitectura completa del proyecto [FlatcarMicroCloud](https://github.com/vhgalvez/FlatcarMicroCloud), incluyendo red pública, túnel VPN, balanceadores Ingress, clúster Kubernetes con K3s, almacenamiento distribuido y servicios esenciales.

## Resumen del Flujo

1. **Ingreso de Conexiones Externas**:  
   Las conexiones HTTPS externas ingresan a través de la IP pública del servidor físico, pasando por un proxy seguro configurado en **Cloudflare CDN** para protección contra ataques DDoS y caché de contenido.

2. **Acceso Seguro**:  
   El tráfico es redirigido al **WireGuard VPN Gateway** (IP túnel: 10.17.0.1) y luego al **Bastion Node** (192.168.0.19), que actúa como punto de acceso seguro a la red interna.

3. **Distribución de Tráfico**:  
   Los balanceadores de carga **Load Balancer1** y **Load Balancer2** (Traefik) distribuyen el tráfico hacia los nodos maestros y workers, asegurando alta disponibilidad y balanceo eficiente.

4. **Resolución de Nombres y Sincronización de Tiempo**:  
   El nodo **infra-cluster** (10.17.3.11) actúa como servidor **DNS** (CoreDNS) y **NTP** (Chrony), proporcionando resolución de nombres y sincronización temporal precisa en todo el clúster.

5. **Ejecución de Aplicaciones**:  
   Los **nodos workers** ejecutan las aplicaciones y microservicios, mientras que los **nodos maestros** gestionan el plano de control de Kubernetes. Todos los nodos mantienen sincronización temporal mediante **chronyc**.

## Arquitectura de Kubernetes (Cluster K3s)

![Cluster K3s](additional_resources/image/cluster_k3s.jpg)

## Interfaz Web de Administración (Cockpit en Rocky Linux)

![Cockpit en Rocky Linux - Login](additional_resources/image/cockpit-rocky-linux-dashboard-login.png)

![Cockpit en Rocky Linux - Login](additional_resources/image/cockpit-rocky-linux-dashboard-metrics.png)

Pantalla de inicio de sesión de **Cockpit**, una interfaz web para administrar servidores **Rocky Linux** de forma remota y gráfica. Permite monitorear el sistema, gestionar servicios, redes, usuarios y acceder a una terminal sin depender exclusivamente de la línea de comandos.

## Longhorn instalado en el clúster K3s

![alt text](additional_resources/image/k3s_ansible_Longhorn_02.png)

![alt text](additional_resources/image/k3s_ansible_Longhorn.png)

---

## 🌐 Configuración de Redes Virtuales con pfSense

![pfSense](additional_resources/image/pfSense.jpg)

Esta sección te guía en la configuración de redes virtuales utilizando **pfSense como firewall** dentro de tu infraestructura KVM. Aprovecha el proyecto automatizado con Terraform para desplegar pfSense rápidamente como una máquina virtual lista para enrutar tráfico entre redes virtualizadas.

---

### 🔗 Repositorio Oficial

Accede al código fuente y plantillas de Terraform en el siguiente repositorio:

[📦 GitHub – terraform-pfsense-kvm-libvirt](https://github.com/vhgalvez/terraform-pfsense-kvm-libvirt)

---

### 🚀 Clona el repositorio

Para comenzar con la configuración:

```bash
git clone https://github.com/vhgalvez/terraform-pfsense-kvm-libvirt.git
cd terraform-pfsense-kvm-libvirt
```

---

## 🔧 Recursos Adicionales Soportados por HP – Firmware ProLiant DL380 G7

Consulta y descarga actualizaciones oficiales de firmware y software para tu servidor HP desde el portal de soporte de Hewlett Packard Enterprise:

- [🔗 Firmware HP ProLiant DL380 G7 – Página oficial de soporte](https://support.hpe.com/connect/s/softwaredetails?collectionId=MTX-5db24d8d46d14448&language=en_US&tab=releaseNotes)

## 💿 Imágenes de Disco para VMs

## ✅ Flatcar para KVM/Libvirt: Descarga y preparación

### 🔽 1. Descargar imagen comprimida

```bash
sudo curl -O https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2
```

### 🔐 2. (Opcional) Verificar firma

```bash
sudo curl -O https://www.flatcar.org/security/image-signing-key/Flatcar_Image_Signing_Key.asc
gpg --import Flatcar_Image_Signing_Key.asc
sudo curl -O https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2.sig
gpg --verify flatcar_production_qemu_image.img.bz2.sig flatcar_production_qemu_image.img.bz2
```

### 📦 3. Descomprimir imagen

```bash
bunzip2 flatcar_production_qemu_image.img.bz2
```

Resultado:

```bash
flatcar_production_qemu_image.img
```

> Lista para usar con Terraform, libvirt o virt-manager.

### 🐧 AlmaLinux 9.5 Generic Cloud (QCOW2)

```bash
curl -o alma9-generic.qcow2 https://repo.almalinux.org/almalinux/9.5/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2
```

---

## 📦 Repositorio del Script SSH Compartido

Este repositorio utiliza un script externo para la generación centralizada de claves SSH compartidas para todas las VMs del clúster.

🔗 Repositorio: [generate_shared_ssh_key](https://github.com/vhgalvez/generate_shared_ssh_key.git)

Puedes clonarlo directamente con:

```bash
git clone https://github.com/vhgalvez/generate_shared_ssh_key.git
```

## Repositorio de Kubectl AI kubernetes agente de inteligencia artificial

```bash
https://github.com/GoogleCloudPlatform/kubectl-ai.git
```

Este script es útil si estás automatizando la creación de máquinas virtuales con Terraform y necesitas una clave reutilizable para conectarte vía SSH con Flatcar.

## ✍️ Autor

**Víctor Hugo Gálvez Sastoque**  
Especialista en DevOps, Infraestructura, Kubernetes y Automatización.  
Ingeniero con visión estratégica orientado a soluciones escalables y eficientes.

- 🌐 **GitHub:** [@vhgalvez](https://github.com/vhgalvez)
- 💼 **LinkedIn:** [victor-hugo-galvez-sastoque](https://www.linkedin.com/in/victor-hugo-galvez-sastoque/)
