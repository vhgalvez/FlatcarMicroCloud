# ☸️ FlatcarMicroCloud - Infraestructura Kubernetes Optimizada para Servidores Físicos

## 📘 Tabla de Contenido

- [☸️ FlatcarMicroCloud - Infraestructura Kubernetes Optimizada para Servidores Físicos](#️-flatcarmicrocloud---infraestructura-kubernetes-optimizada-para-servidores-físicos)
  - [📘 Tabla de Contenido](#-tabla-de-contenido)
  - [🏢 Resumen Teórico de la Arquitectura de Infraestructura Global - FlatcarMicroCloud](#-resumen-teórico-de-la-arquitectura-de-infraestructura-global---flatcarmicrocloud)
    - [✨ Objetivo del Proyecto](#-objetivo-del-proyecto)
    - [🌎 Flujo Global de Infraestructura](#-flujo-global-de-infraestructura)
    - [🚀 Clúster Kubernetes (K3s)](#-clúster-kubernetes-k3s)
    - [📂 Almacenamiento Distribuido](#-almacenamiento-distribuido)
    - [🛡️ Seguridad en Capas](#️-seguridad-en-capas)
    - [🎓 Servicios Complementarios](#-servicios-complementarios)
    - [🏠 Automatización](#-automatización)
    - [📊 Resultado Final](#-resultado-final)


## 🏢 Resumen Teórico de la Arquitectura de Infraestructura Global - FlatcarMicroCloud

### ✨ Objetivo del Proyecto

Automatizar una infraestructura moderna de Kubernetes con almacenamiento distribuido, alta disponibilidad, seguridad avanzada, y bajo presupuesto. Todo desplegado sobre servidores físicos y VMs usando herramientas como K3s, Traefik, Longhorn, NFS, WireGuard y Ansible.

---

### 🌎 Flujo Global de Infraestructura

1. Usuari**os Públicos** acceden a dominios en Cloudflare.
2. **Cloudflare** actúa como CDN, Proxy, WAF y Anti-DDoS.
3. El tráfico HTTPS es redirigido a un **VPS con IP Pública** que actúa como **Gateway VPN WireGuard**.
4. El tráfico VPN viaja hasta el entorno LAN físico mediante tunelado seguro (IP 10.17.0.1).
5. Dentro de la red LAN, el tráfico pasa por un **pfSense (Firewall)** que implementa reglas de NAT, IDS/IPS y control de acceso.
6. Luego, el tráfico llega a los balanceadores **Traefik** (2 nodos) expuestos en la red interna.
7. Los Traefik reenvían el tráfico HTTP/HTTPS a un clúster **HAProxy + Keepalived**, que balancea la carga entre 3 master nodes de Kubernetes a través de una IP virtual VIP (10.17.5.10).

---

### 🚀 Clúster Kubernetes (K3s)

- **3 Master Nodes** (10.17.4.21, .22, .23): etcd + control plane
- **3 Worker Nodes** (10.17.4.24, .25, .26): microservicios y aplicaciones
- **1 Nodo Storage** (10.17.4.27): NFS + Longhorn

---

### 📂 Almacenamiento Distribuido

**storage1** (10.17.4.27) gestiona:

- `/srv/nfs/postgresql` ➜ Datos persistentes para PostgreSQL
- `/srv/nfs/shared` ➜ Datos compartidos entre pods (RWX)
- `/mnt/longhorn-disk` ➜ Volúmenes distribuidos Longhorn (RWO)

**Cliente NFS**:

- Nodo PostgreSQL monta `/srv/nfs/postgresql`
- Pods con acceso RWX montan `/srv/nfs/shared`

**Cliente Longhorn**:

- Prometheus, Grafana, ELK, apps, microservicios

---

### 🛡️ Seguridad en Capas

- **Cloudflare**: HTTPS, Anti-DDoS, DNSSEC
- **WireGuard VPN**: Acceso remoto seguro desde VPS público
- **pfSense**: Firewall, NAT, reglas de acceso, IDS
- **Red privada 10.17.0.0/16**: Todo el tráfico del clúster permanece aislado

---

### 🎓 Servicios Complementarios

- **FreeIPA** (10.17.3.11): DNS interno + autenticación centralizada
- **PostgreSQL** (10.17.3.14): Base de datos central
- **Prometheus, Grafana, ELK, Redis, Kafka**: Observabilidad y mensajería para microservicios

---

### 🏠 Automatización

- **Ansible**: Automatiza configuración de volúmenes, NFS y despliegue de servicios
- **Terraform**: Provisión de VMs y discos
- **K3s**: Instalación ligera de Kubernetes

---

### 📊 Resultado Final

- Alta disponibilidad: 3 masters + HAProxy
- Red segura: pfSense + WireGuard + Cloudflare
- Escalable: Longhorn y NFS en nodo dedicado
- Ideal para: entornos educativos, laboratorios, entornos de pruebas y MVPs reales

troubleshooting  linux