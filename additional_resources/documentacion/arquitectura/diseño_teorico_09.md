📌 Guía del Proyecto: Arquitectura de Microservicios con Kubernetes 🚀
Este documento describe la arquitectura, componentes y estrategia de despliegue del proyecto, asegurando escalabilidad, alta disponibilidad y automatización.

1️⃣ Arquitectura General
El sistema se basa en microservicios desplegados en Kubernetes con Traefik como Ingress Controller.
Cada microservicio tiene su propósito y usa las mejores tecnologías para su función.

📌 Componentes Clave:
Componente	Descripción	Tecnología
Nginx Proxy	Maneja el tráfico HTTP y balanceo de carga interno.	Nginx
Frontend (Vue.js)	Aplicación web SPA servida por Nginx.	Vue.js + Nginx
Backend (FastAPI)	API principal para lógica de negocio y gestión de usuarios.	FastAPI + Uvicorn
Base de Datos (PostgreSQL)	Base de datos principal en una máquina virtual separada.	PostgreSQL (IP: 10.17.3.14)
Mensajería (Apache Kafka)	Comunicación asíncrona entre microservicios.	Apache Kafka
Almacenamiento (Longhorn + NFS)	Persistencia distribuida para servicios y datos compartidos.	Longhorn (10.17.4.27) + NFS
Observabilidad (ELK + Prometheus + Grafana)	Monitoreo y visualización de logs y métricas.	Elasticsearch, Logstash, Kibana, Prometheus, Grafana
CI/CD (ArgoCD + Jenkins)	Despliegue automatizado y control de versiones.	ArgoCD + Jenkins
Ingress Controller (Traefik)	Manejo de tráfico y certificados SSL.	Traefik
2️⃣ Infraestructura y Despliegue
Los microservicios corren en un cluster Kubernetes con almacenamiento persistente en Longhorn y logs en ELK Stack.

📌 Infraestructura:
Servicio	Ubicación
Kubernetes Masters	10.17.4.21, 10.17.4.22, 10.17.4.23
Kubernetes Workers	10.17.4.24, 10.17.4.25, 10.17.4.26
Load Balancer (Traefik)	10.17.3.12, 10.17.3.13
Base de Datos (PostgreSQL)	10.17.3.14
Almacenamiento (Longhorn + NFS)	10.17.4.27
VPN y acceso remoto	VPS con WireGuard
3️⃣ Flujos de Trabajo y Comunicación
La arquitectura sigue un patrón de microservicios desacoplados, con Kafka como middleware de mensajería.

✅ Frontend (Vue.js) → Backend (FastAPI) → PostgreSQL
✅ Backend (FastAPI) → Kafka → Otros microservicios
✅ Kafka distribuye eventos entre microservicios
✅ Nginx gestiona tráfico entre frontend y backend
✅ Traefik maneja la exposición y el enrutamiento
✅ Logs y métricas van a ELK y Prometheus/Grafana

4️⃣ Fases de Implementación
Dividimos el proyecto en fases para enfocarnos en cada parte antes de exponerlo públicamente.

📌 Fase 1: Preparación del Entorno
✅ Configurar Kubernetes con Traefik como Ingress Controller
✅ Implementar almacenamiento en Longhorn y NFS
✅ Desplegar PostgreSQL en su máquina virtual
✅ Configurar Apache Kafka para comunicación entre microservicios
✅ Implementar monitoreo con Prometheus y Grafana

📌 Fase 2: Despliegue de Microservicios
✅ Desplegar microservicio de frontend (Vue.js + Nginx)
✅ Desplegar backend (FastAPI + PostgreSQL + Kafka)
✅ Configurar comunicación entre microservicios con Kafka

📌 Fase 3: CI/CD y Observabilidad
✅ Automatizar despliegues con ArgoCD y Jenkins
✅ Implementar ELK Stack para logs y alertas
✅ Configurar métricas con Prometheus y Grafana

📌 Fase 4: Exposición Pública
✅ Implementar VPN con VPS para acceso remoto seguro
✅ Configurar Cloudflare como CDN y protección DDoS
✅ Exponer servicios al público con dominio personalizado

5️⃣ Estrategia de Escalabilidad
Para garantizar alto rendimiento y disponibilidad, seguimos estas estrategias:

✅ Balanceo de carga con Traefik
✅ Microservicios independientes y escalables
✅ Persistencia en Longhorn para alta disponibilidad
✅ Kafka como middleware para desacoplar servicios
✅ CI/CD con ArgoCD y Jenkins para automatización
✅ Monitoreo en tiempo real con Prometheus y Grafana



📌 PASO 1: Generar Certificados SSL para Traefik
Antes de instalar Traefik, necesitas certificados SSL para manejar tráfico seguro.

Ejecutar:

bash
Copiar
Editar
sudo ansible-playbook -i inventory/hosts.ini generate_certs.yml
📌 Tareas clave en generate_certs.yml:
✅ Instalación de cryptography para manejar claves SSL.
✅ Creación del directorio /etc/traefik/certs.
✅ Generación de una clave privada y un certificado autofirmado.
✅ Validación del certificado generado.

📌 PASO 2: Instalar PyPy en Flatcar Linux
Flatcar no tiene Python por defecto, así que necesitamos instalar PyPy para que Ansible pueda ejecutar tareas en los nodos.

Ejecutar:

bash
Copiar
Editar
sudo ansible-playbook -i inventory/hosts.ini install_PyPy.yml
📌 Tareas clave en install_PyPy.yml:
✅ Descarga y extracción de PyPy si no está instalado.
✅ Creación de un enlace simbólico /opt/bin/python.
✅ Verificación de la instalación ejecutando /opt/bin/python --version.

📌 PASO 3: Instalar kubectl y Configurar Kubeconfig en los Nodos
Para que los Load Balancers puedan gestionar el tráfico, deben comunicarse con Kubernetes.

Ejecutar:

bash
Copiar
Editar
sudo ansible-playbook -i inventory/hosts.ini install_kubectl_and_kubeconfig.yml
📌 Tareas clave en install_kubectl_and_kubeconfig.yml:
✅ Instalación de kubectl en los nodos Load Balancer.
✅ Copia del archivo kubeconfig desde el nodo maestro (10.17.4.21) a los Load Balancers.
✅ Validación de que kubectl funciona correctamente.

📌 PASO 4: Instalar y Configurar Traefik como Ingress Controller
Este es el paso más importante: instalar Traefik y exponerlo como Ingress Controller.

Ejecutar:

bash
Copiar
Editar
sudo ansible-playbook -i inventory/hosts.ini install_traefik.yml
📌 Tareas clave en install_traefik.yml:
✅ Instalación y configuración de Docker en los Load Balancers.
✅ Creación del namespace traefik en Kubernetes.
✅ Despliegue de Traefik como Deployment en Kubernetes.
✅ Exposición de Traefik mediante un Service LoadBalancer.
✅ Verificación del estado de los Pods de Traefik.

📌 ARQUITECTURA FINAL
📌 Infraestructura y roles en Kubernetes:

pgsql
Copiar
Editar
+------------------------+       +--------------------------+
|     Load Balancer 1    |       |       Load Balancer 2    |
| (Traefik Ingress)      |       | (Traefik Ingress)       |
|  10.17.3.12           |       | 10.17.3.13              |
+------------------------+       +--------------------------+
            |                              |
            |                              |
+------------------------------------------------------+
|                    Kubernetes Cluster               |
| +-------------+ +-------------+ +-------------+    |
| |  Master 1   | |  Master 2   | |  Master 3   |    |
| |  10.17.4.21 | |  10.17.4.22 | |  10.17.4.23 |    |
| +-------------+ +-------------+ +-------------+    |
| +----------------------+ +----------------------+ |
| |    Worker 1         | |    Worker 2         |  |
| |   10.17.4.24       | |   10.17.4.25       |  |
| +----------------------+ +----------------------+ |
+------------------------------------------------------+
📌 Base de datos y almacenamiento externo:

PostgreSQL → 10.17.3.14 (Máquina virtual externa)
Longhorn (Almacenamiento distribuido) → 10.17.4.27





 Explicación de la Arquitectura
✅ pfSense (192.168.0.200)

Firewall central de la infraestructura.
Controla tráfico interno y externo.
IDS/IPS activado para monitoreo.
✅ Load Balancers (Traefik - 10.17.3.12 y 10.17.3.13)

Manejan el tráfico HTTP/S dentro del clúster.
Integrados con Kubernetes como Ingress Controller.
✅ HAProxy + Keepalived (VIP 10.17.3.10)

Balancea las peticiones a la API de Kubernetes.
Failover automático: Si un master falla, redirige tráfico a otro.
✅ Master Nodes (etcd - 10.17.4.21, 10.17.4.22, 10.17.4.23)

Kubernetes Control Plane.
Alta disponibilidad con HAProxy.
✅ Workers Nodes

Ejecutan los workloads y servicios de Kubernetes.
✅ FreeIPA (10.17.3.11), PostgreSQL (10.17.3.14), Storage (10.17.4.27)

FreeIPA: DNS y autenticación.
PostgreSQL: Base de datos principal.
Storage Node: Almacenamiento distribuido.
🔥 Resumen Técnico
✅ Mejor organización de tráfico entre Ingress, API y workloads.
✅ Separación lógica y seguridad mejorada con pfSense y HAProxy.
✅ Alta disponibilidad (HA) con Keepalived en la API.
✅ Optimización para Kubernetes, balanceo de carga y escalabilidad.
Esta es la arquitectura óptima para seguridad, alta disponibilidad y rendimiento. 🚀

Dime si quieres ajustes o mejoras. 🔥



          +--------------------+--------------------+
          |                                         |
          v                                         v
+---------------------------+         +---------------------------+
|  Load Balancer 1 (Traefik)|         |  Load Balancer 2 (Traefik)|
|      IP: 10.17.3.12       |         |      IP: 10.17.3.13       |
|  (Ingress Controller)     |         |  (Ingress Controller)     |
+---------------------------+         +---------------------------+
                                   |
                                   v
          +--------------------------------------------------+
          |   HAProxy + Keepalived (Alta Disponibilidad)     |
          |           k8s-api-lb - VIP: 10.17.5.10           |
          |  - Balanceo de la API de Kubernetes              |
          |  - Failover automático entre Masters             |
          +--------------------------------------------------+
                                   |
                                   v
                   +---------------------------+---------------------------+
                   |                           |                           |
                   v                           v                           v
          +------------------+       +------------------+       +------------------+
          |  Master Node 1   |       |  Master Node 2   |       |  Master Node 3   |
          |       (etcd)     |       |       (etcd)     |       |       (etcd)     |
          |    10.17.4.21    |       |    10.17.4.22    |       |    10.17.4.23    |
          +------------------+       +------------------+       +------------------+
