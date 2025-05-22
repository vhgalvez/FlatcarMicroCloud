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
+-------------------------------------------+     +-------------------------------------------+
| Keepalived + HAProxy (VIP: 10.17.5.10)    |     | Keepalived + HAProxy (VIP: 10.17.5.30)    |
| Balancea tráfico al puerto 6443 (API)     |     | Balancea tráfico a puertos 80 y 443       |
+-------------------------------------------+     +-------------------------------------------+
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
| loadbalancer1 | 10.17.3.12 | HAProxy + Keepalived (Backup 1)  | 2   | 2048     | 32         |
| loadbalancer2 | 10.17.3.13 | HAProxy + Keepalived (Backup 2)  | 2   | 2048     | 32         |
| postgresql1   | 10.17.3.14 | Base de datos PostgreSQL         | 2   | 2048     | 32         |
| k8s-api-lb    | 10.17.5.20 | HAProxy + Keepalived (VIP Owner) | 2   | 2048     | 80         |

### ✅ Características Clave

* Separación de tráfico API (6443) y Web (80/443) mediante VIPs distintas.
* Traefik se ejecuta **dentro del clúster** como `Deployment`, enruta a servicios Kubernetes.
* HAProxy + Keepalived con tolerancia a fallos y failover automático.
* Seguridad con WireGuard, nftables, y Cloudflare.
* NFS + Longhorn garantizan persistencia y disponibilidad de datos.
* Arquitectura modular, completamente automatizada con Terraform + Ansible.

---

### 🔁 Flujo de Tráfico Simplificado

```
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

──────────────────────────────────────

         Acceso interno y Kubelets
                      ↓
      +-----------------------------+
      |  VIP: 10.17.5.10 (HAProxy)  |
      |      Kubernetes API         |
      +-----------------------------+
                      ↓
     Se comunica con Master1/2/3 vía TCP 6443
```
