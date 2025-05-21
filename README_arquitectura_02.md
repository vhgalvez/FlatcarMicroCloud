## Arquitectura de FlatcarMicroCloud

### 🌐 Infraestructura Global y Accesos Externos

```
[Usuarios Públicos]
       │
       ▼
+-------------------+
| Cloudflare CDN    | ◇┌ Proxy + WAF + HTTPS
| (example.com)     |
+-------------------+
       │
       ▼
+----------------------------+
| VPS Externo (IP pública)  |
| WireGuard Gateway         |
| Túnel: 10.17.0.1          |
+----------------------------+
       │
       ▼
+-----------------------------+
| WireGuard Server LAN        |
| NAT + VPN (192.168.0.15)    |
+-----------------------------+
       │
       ▼
      🔐 Redirige tráfico interno según tipo

🟢 Tráfico Kubernetes API:                  🔹 Tráfico Ingress Web:
       ▼                                            ▼
+-----------------------------------+     +-----------------------------------+
| Keepalived + HAProxy (API)        |     | Keepalived + HAProxy (Ingress)    |
| VIP: 10.17.5.10:6443              |     | VIP: 10.17.5.30:80,443            |
+-----------------------------------+     +-----------------------------------+
       │                                            │
       ▼                                            ▼
+----------------+  +----------------+  +----------------+         +------------------------+
| master1        |  | master2        |  | master3        | <---->  | Traefik Deployment      |
| 10.17.4.21     |  | 10.17.4.22     |  | 10.17.4.23     |         | (en pods del clúster)   |
| etcd + API     |  | etcd           |  | etcd           |         +------------------------+
+----------------+  +----------------+  +----------------+                  │
                                                                       Rutas internas
                                                                            │
                                                                            ▼
                                                                 +----------------------+
                                                                 | Servicios Kubernetes |
                                                                 | Pods, Deployments    |
                                                                 +----------------------+
```

### ⚙️ Nodo de Almacenamiento y Otros Servicios

```
+----------------+ +----------------+ +----------------+ +----------------+
| worker1        | | worker2        | | worker3        | | storage1       |
| 10.17.4.24     | | 10.17.4.25     | | 10.17.4.26     | | 10.17.4.27     |
| Longhorn       | | Longhorn       | | Longhorn       | | NFS + Longhorn |
+----------------+ +----------------+ +----------------+ +----------------+

🔗 PVCs de Longhorn:
- Microservicios
- Prometheus
- Grafana

🔗 NFS Mounts:
- PostgreSQL Node → /srv/nfs/postgresql
- Pods con PVC RWX → /srv/nfs/shared

📦 Otros Roles:
- infra-cluster (10.17.3.11): DNS + NTP (Chrony)
- postgresql1 (10.17.3.14): Base de datos PostgreSQL
```

### 🖥 Tabla de Máquinas

| Hostname      | IP         | Función                          | CPU | RAM (MB) | Disco (GB) |
| ------------- | ---------- | -------------------------------- | --- | -------- | ---------- |
| master1       | 10.17.4.21 | Control Plane Kubernetes         | 2   | 4096     | 50         |
| master2       | 10.17.4.22 | Control Plane Kubernetes         | 2   | 4096     | 50         |
| master3       | 10.17.4.23 | Control Plane Kubernetes         | 2   | 4096     | 50         |
| worker1       | 10.17.4.24 | Nodo Worker Kubernetes           | 2   | 4096     | 50         |
| worker2       | 10.17.4.25 | Nodo Worker Kubernetes           | 2   | 4096     | 50         |
| worker3       | 10.17.4.26 | Nodo Worker Kubernetes           | 2   | 4096     | 50         |
| storage1      | 10.17.4.27 | NFS + Longhorn Storage           | 2   | 2048     | 80         |
| infra-cluster | 10.17.3.11 | DNS + NTP Chrony                 | 2   | 2048     | 32         |
| loadbalancer1 | 10.17.3.12 | Ingress Controller (HAProxy LB1) | 2   | 2048     | 32         |
| loadbalancer2 | 10.17.3.13 | Ingress Controller (HAProxy LB2) | 2   | 2048     | 32         |
| postgresql1   | 10.17.3.14 | Base de datos PostgreSQL         | 2   | 2048     | 32         |
| k8s-api-lb    | 10.17.5.20 | VIP API HAProxy + Keepalived     | 2   | 2048     | 80         |


### ✅ Características Clave

* Separación de tráfico API y HTTP con VIPs distintas.
* Traefik corre **dentro del clúster** como `Deployment`, accede a los pods por ClusterIP.
* Alta disponibilidad en controladores de Ingress y Kubernetes API.
* Seguridad garantizada por WireGuard y nftables.
* Escalabilidad horizontal con nodos adicionales.

---

Este documento refleja la arquitectura actualizada de FlatcarMicroCloud con una configuración de producción robusta y modular.



                               Tráfico HTTP/HTTPS Público
                                          ↓
                          +-----------------------------+
                          |  VIP: 10.17.5.30 (HAProxy)  |
                          +-----------------------------+
                                      ↓
                      Redirige al servicio Traefik interno
                                      ↓
                           Traefik (Deployment en K3s)
                                      ↓
                          Services, Pods y Microservicios

                      ───────────────────────────────────

                             Acceso interno y Kubelets
                                         ↓
                          +-----------------------------+
                          |  VIP: 10.17.5.10 (HAProxy)  |
                          |      Kubernetes API         |
                          +-----------------------------+
                                       ↓
                     Se comunica con Master1, Master2, Master3
