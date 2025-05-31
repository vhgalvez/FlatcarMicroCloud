## Arquitectura de FlatcarMicroCloud

### 🌐 Infraestructura Global y Accesos Externos

```
[Usuarios Públicos]
       │
       ▼
+-------------------+
| Cloudflare CDN    | ◄── Proxy + HTTPS + WAF
| (example.com)     |
+-------------------+
       │
       ▼
+----------------------------+
| Internet con IP dinámica   |
+----------------------------+
       │
       ▼
+-----------------------------+
| Router ISP (LAN: 192.198.0.30) |
| NAT + Port Forwarding        |
| Puertos 80, 443, 51820/UDP   |
+-----------------------------+
       │
       ▼
Tráfico Interno Redirigido Según Tipo
```

### 🎯 Separación de Tráfico en Producción

| Tipo de Tráfico       | VIP Asignada | Función                                                |
| --------------------- | ------------ | ------------------------------------------------------ |
| Kubernetes API (6443) | 10.17.5.10   | Tráfico hacia kube-apiserver (VIP usada en kubeconfig) |
| Ingress HTTP/HTTPS    | 10.17.5.30   | Redirige tráfico a servicios internos vía Traefik      |

Estas VIPs son gestionadas por HAProxy + Keepalived. Traefik maneja el tráfico entrante HTTP/HTTPS desde la VIP `10.17.5.30` hacia los `IngressRoute` definidos dentro del clúster.

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

### 🧩 Red Física y Conectividad del Servidor

**🖥 Servidor Central (Bare Metal):**

* Modelo: ProLiant DL380 G7
* CPU: Intel Xeon X5650 (24 cores) @ 2.666GHz
* RAM: 35 GB
* Almacenamiento: 1.5 TB (principal), 3.0 TB (secundario)

**🔌 Conectividad Física y Dispositivos de Red:**

* Switch: TP-Link LS1008G (8 puertos Gigabit no administrados)
* Router ISP: Fibra óptica, IP pública, 600 Mbps subida/bajada
* VPN: WireGuard instalado para acceso seguro (Puerto 51820/UDP abierto en router)
* Seguridad adicional: nftables para reglas de firewall

**🌐 Interfaces de Red del Servidor:**

|

> Interfaces asignadas a bridges virtuales con KVM. `enp3s0f0` enlazado a bridge `br-api` para tráfico VIP de API y servicios Ingress.

### 🖧 Tabla de Nodos del Clúster

| Hostname      | IP           | Función                    | CPU | RAM (MB) | Disco (GB) |
| ------------- | ------------ | -------------------------- | --- | -------- | ---------- |
| master1       | 10.17.4.21   | Control Plane Kubernetes   | 2   | 4096     | 50         |
| master2       | 10.17.4.22   | Control Plane Kubernetes   | 2   | 4096     | 50         |
| master3       | 10.17.4.23   | Control Plane Kubernetes   | 2   | 4096     | 50         |
| worker1       | 10.17.4.24   | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| worker2       | 10.17.4.25   | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| worker3       | 10.17.4.26   | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| storage1      | 10.17.4.27   | NFS + Longhorn Storage     | 2   | 2048     | 80         |
| infra-cluster | 10.17.3.11   | DNS coredns / ntp  Chrony  | 2   | 2048     | 32         |
| loadbalancer1 | 10.17.3.12   | Ingress Controller Traefik | 2   | 2048     | 32         |
| loadbalancer2 | 10.17.3.13   | Ingress Controller Traefik | 2   | 2048     | 32         |
| postgresql1   | 10.17.3.14   | Base de datos PostgreSQL   | 2   | 2048     | 32         |
| k8s-api-lb    | 192.168.0.30 | Nodo físico puente VIPs    | 2   | 2048     | 80         |

---

### ✅ Características Clave

* Alta disponibilidad real con múltiples VIPs separadas.
* Ingress controlado por Traefik vía VIP `10.17.5.30`.
* API Kubernetes accesible vía VIP `10.17.5.10`.
* Seguridad reforzada por VPN, nftables y Cloudflare DNS.
* Automatización completa con Terraform y Ansible.
* Soporte para dominio público y certificados Let’s Encrypt.
* Uso de WireGuard para administración remota segura.
* Configuración modular, extensible, y tolerante a fallos.