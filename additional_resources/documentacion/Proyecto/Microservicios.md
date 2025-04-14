# Implementación del Proyecto CI/CD con Microservicios en K3s

## Objetivo General

Implementar un entorno de integración y entrega continua (CI/CD) para una arquitectura de microservicios sobre un clúster Kubernetes (K3s), utilizando herramientas modernas como Jenkins, ArgoCD, Prometheus, Grafana, Redpanda, RabbitMQ, Vue.js, FastAPI, PostgreSQL, Longhorn, NFS, y Traefik. Este documento detalla el enfoque estructurado para la implementación, especificando qué automatizar con **Ansible**, qué con **Terraform**, y cómo aplicar la integración y entrega continua (CI/CD) usando **Jenkins** y **ArgoCD**.

---

## **Repositorios del Proyecto**

### 1. `microservices-infra`

**Infraestructura base para el clúster K3s:**
- Jenkins (CI)
- ArgoCD (CD)
- Traefik (Ingress)
- Redpanda (Kafka-like)
- RabbitMQ
- Almacenamiento: NFS + Longhorn
- Longhorn replicados en Workers
- Ansible para el aprovisionamiento seguro de almacenamiento

### 2. `microservices-apps`

**Repositorio GitOps:**
- Contiene manifiestos YAML/Helm de todos los microservicios y servicios.
- Usado por ArgoCD para sincronizar despliegues.

### 3. `producer-service`

**Microservicio FastAPI que produce eventos:**
- Publica en Redpanda.
- RabbitMQ para comunicación de servicios.
- CI/CD con Jenkins + GHCR.

### 4. `consumer-service`

**Microservicio FastAPI que consume eventos:**
- Lee desde Redpanda y RabbitMQ.
- CI/CD con Jenkins + GHCR.

### 5. `frontend-vue-service`

**Aplicación web Vue.js:**
- Se construye con `npm run build`.
- CI/CD con Jenkins + GHCR.

### 6. `nginx-web-server`

**Servidor Nginx como microservicio:**
- Sirve el frontend desde volumen NFS.
- Expone la app pública vía Traefik.

---

## **Tecnologías utilizadas**

- **Kubernetes (K3s):** Clúster ligero y con alta disponibilidad.
- **Jenkins:** Automatización de CI.
- **ArgoCD:** GitOps y despliegue automático.
- **Redpanda:** Reemplazo liviano de Kafka para eventos.
- **RabbitMQ:** Sistema de colas para tareas asíncronas.
- **FastAPI:** Backend ligero y rápido para microservicios.
- **Vue.js:** Frontend moderno y flexible.
- **Nginx:** Servidor web para archivos estáticos.
- **PostgreSQL (externo):** Base de datos.
- **NFS + Longhorn:** Almacenamiento persistente.
- **GHCR:** Registro de contenedores gratuito (GitHub Container Registry).

---

## **Estructura de almacenamiento**

- `/srv/nfs/postgresql`: Volumen compartido para la base de datos.
- `/srv/nfs/shared`: Archivos comunes (frontend, logs, etc.).
- `/mnt/longhorn-disk`: Volúmenes RWO de aplicaciones.

**Provisionado con Ansible:**
- `flatcar-k3s-storage-suite`
- Roles: `storage_setup`, `longhorn_worker`, `install_longhorn.yml`

---

## **Flujo CI/CD completo**

1. **Desarrollador hace push a GitHub:**
   - Se sube el código del microservicio correspondiente (por ejemplo, `producer-service` o `consumer-service`).

2. **Jenkins:**
   - Jenkins detecta el cambio y ejecuta el pipeline de **CI**:
     - **Construcción** de la imagen del contenedor.
     - **Pruebas automáticas** (unitarias y de integración).
     - **Publicación** de la imagen en el registro (GHCR).

3. **ArgoCD:**
   - ArgoCD detecta el cambio en el repositorio **microservices-apps** y sincroniza el despliegue con Kubernetes.
   - ArgoCD realiza el despliegue del nuevo microservicio al clúster **K3s**.

4. **Despliegue en K3s:**
   - El servicio se despliega automáticamente en el clúster **K3s**, utilizando **Traefik** como Ingress para el acceso al frontend o servicios.

---

## **Checklist de Tareas**

### **Infraestructura Base (Automatización con Terraform y Ansible)**

- **Terraform**:
  - Provisionar infraestructura en la nube (si aplica) con máquinas virtuales, redes y almacenamiento.
  - Provisión de nodos de Kubernetes en la nube o máquinas físicas.
  - Creación de redes (VPC, subredes) y balanceadores de carga si se usa en la nube.

- **Ansible**:
  - Instalar y configurar **K3s** en los nodos.
  - Configurar **nodos master** y **workers**.
  - Aprovisionar almacenamiento con **Longhorn** y **NFS**.
  - Instalar y configurar **Jenkins**, **Prometheus**, **Grafana**, **RabbitMQ**, **Redpanda**, **PostgreSQL**, y **Traefik**.

---

### **Servicios Internos (Automatización con Ansible)**

- **Instalar y configurar Prometheus**:
  - Usar **Helm** para instalar **Prometheus** y **Grafana**.
  - Configurar almacenamiento persistente con **Longhorn** y **NFS**.

- **Configurar Redpanda y RabbitMQ**:
  - Implementar estos servicios de mensajería en el clúster para gestionar eventos y colas de tareas.

- **Configurar PostgreSQL**:
  - Asegurarse de que **PostgreSQL** esté bien configurado, ya sea dentro de Kubernetes o fuera de él.

- **Configurar Ingress (Traefik)**:
  - Implementar **Traefik** como Ingress Controller para gestionar el tráfico HTTP/HTTPS en el clúster.

---

### **Microservicios (Automatización con Jenkins)**

- **Jenkins Pipelines**:
  - Configurar **pipelines** de **CI** para la construcción, prueba y despliegue de los microservicios.
  - **Construcción de imágenes** de contenedor y **publicación** en el registro **GHCR**.
  - **Pruebas unitarias y de integración** en cada push al repositorio de código.

---

### **CI/CD (Automatización con Jenkins y ArgoCD)**

- **Jenkins**:
  - **Construcción de imágenes de contenedores**.
  - **Pruebas automáticas** (unitarias e integración).
  - **Publicación en GHCR** para las imágenes de contenedor.

- **ArgoCD**:
  - **GitOps**: Configurar ArgoCD para sincronizar los despliegues automáticamente con los manifiestos YAML/Helm.
  - **Despliegue automático** de las nuevas versiones de los microservicios a Kubernetes.

---

### **Observabilidad (Opcional)**

- **Prometheus y Grafana**:
  - **Monitoreo** de todos los microservicios y recursos dentro de Kubernetes.
  - Configuración de **alertas** en Prometheus y visualización de métricas en Grafana.

---

## **Automatización con Ansible, Terraform, Jenkins y ArgoCD**

### **Con Ansible:**
- Configuración de **K3s** y otros servicios en el clúster (nodos, almacenamiento, VPN, firewalls, etc.).
- Instalación y configuración de **Jenkins**, **Prometheus**, **Grafana**, **RabbitMQ**, **Redpanda**, **PostgreSQL**, etc.
- Aprovisionamiento de almacenamiento con **Longhorn** y **NFS**.

### **Con Terraform:**
- Provisión de infraestructura en la nube (si es necesario).
- Configuración de red y recursos en la nube (nodos de máquinas virtuales, balanceadores de carga, etc.).
- Despliegue de máquinas físicas o virtuales para el clúster de K3s.

### **Con Jenkins (CI):**
- **Pipelines de CI** para construir, probar y empaquetar las aplicaciones.
- Construcción de **imágenes de contenedor** y **publicación** en el registro de contenedores.

### **Con ArgoCD (CD):**
- **GitOps** para sincronizar los despliegues con los manifiestos YAML/Helm.
- **Despliegue automático** de las nuevas versiones de los microservicios a Kubernetes.

---

## **Resumen de la Implementación**

### **Infraestructura Base (Terraform y Ansible)**:
- Provisión del clúster **K3s**, almacenamiento persistente (**Longhorn** y **NFS**), configuración de red (**VPN**, **nftables**).

### **CI (Jenkins)**:
- **Automáticamente construye** las imágenes, **ejecuta pruebas** y **publica** las imágenes.

### **CD (ArgoCD)**:
- **Despliega** las imágenes automáticamente a **K3s** usando **GitOps** y **Helm**.

Esta es la estructura general para la automatización del flujo de trabajo de **CI/CD** en tu entorno **Kubernetes** con **microservicios**.
