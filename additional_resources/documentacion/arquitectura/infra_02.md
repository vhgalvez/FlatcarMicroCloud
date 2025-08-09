# 🧩 FlatcarMicroCloud — Arquitectura K3s HA sobre KVM + HAProxy + Keepalived

## 1️⃣ Inventario maestro (estado actual)

| Nodo / Recurso      | Rol                                             | Red                 | IP / VIP              | vCPU | RAM     | Disco raíz | Extras                | SO / Imagen     | Notas |
|---------------------|-------------------------------------------------|---------------------|-----------------------|------|---------|------------|-----------------------|-----------------|-------|
| **Host físico**     | Hypervisor (KVM/libvirt)                        | 192.168.0.0/24 (br0)| 192.168.0.40           | —    | —       | 35 GB      | —                     | Rocky Linux 9.5 | Puente br0 a LAN, nftables |
| **loadbalancer1**   | L4 LB: HAProxy + Keepalived (**ACTIVE**)         | 192.168.0.0/24      | 192.168.0.30           | 1    | 512 MB  | 30 GB      | —                     | AlmaLinux 9.5   | VRRP prioridad alta |
| **loadbalancer2**   | L4 LB: HAProxy + Keepalived (**BACKUP**)         | 192.168.0.0/24      | 192.168.0.31           | 1    | 512 MB  | 30 GB      | —                     | AlmaLinux 9.5   | Par VRRP |
| **VIP API**         | Entrada K3s API (L4)                             | 192.168.0.0/24      | 192.168.0.32:6443      | —    | —       | —          | —                     | —               | Solo LAN/VPN |
| **VIP Web**         | Entrada HTTP/HTTPS → Traefik                     | 192.168.0.0/24      | 192.168.0.33:80/443    | —    | —       | —          | —                     | —               | Público (Router/CF → VIP) |
| **infra-cluster**   | DNS autoritativo + NTP                           | 10.17.3.0/24        | 10.17.3.11             | 1    | 512 MB  | 32 GB      | —                     | AlmaLinux 9.5   | CoreDNS + Chrony |
| **postgresql1**     | Base de datos                                    | 10.17.3.0/24        | 10.17.3.14             | 2    | 1 GB    | 32 GB      | —                     | AlmaLinux 9.5   | DB central |
| **master1**         | K3s control-plane (etcd)                         | 10.17.4.0/24        | 10.17.4.21             | 2    | 2 GB    | 50 GB      | —                     | Flatcar          | Bootstrap del clúster |
| **master2**         | K3s control-plane (etcd)                         | 10.17.4.0/24        | 10.17.4.22             | 2    | 2 GB    | 50 GB      | —                     | Flatcar          | — |
| **master3**         | K3s control-plane (etcd)                         | 10.17.4.0/24        | 10.17.4.23             | 2    | 2 GB    | 50 GB      | —                     | Flatcar          | — |
| **worker1**         | K3s worker (workloads)                           | 10.17.4.0/24        | 10.17.4.24             | 3    | 8 GB    | 20 GB      | 1×40 GB qcow2         | Flatcar          | Disco Longhorn |
| **worker2**         | K3s worker (workloads)                           | 10.17.4.0/24        | 10.17.4.25             | 3    | 8 GB    | 20 GB      | 1×40 GB qcow2         | Flatcar          | Disco Longhorn |
| **worker3**         | K3s worker (workloads)                           | 10.17.4.0/24        | 10.17.4.26             | 3    | 8 GB    | 20 GB      | 1×40 GB qcow2         | Flatcar          | Disco Longhorn |
| **storage1**        | Storage (Longhorn + NFS)                         | 10.17.4.0/24        | 10.17.4.27             | 2    | 4 GB    | 10 GB      | 1×80 GB qcow2         | Flatcar          | Volúmenes + exports |

> **TZ:** Europe/Madrid — **VPN:** WireGuard — **Firewall:** nftables en `192.168.0.40` — **SSH:** Claves inyectadas por cloud-init.

---

## 2️⃣ Redes y gateways

### 🌐 LAN (bridge `br0`) — `192.168.0.0/24`

- **Gateway:** `192.168.0.1` (router físico)  
- **LBs:** `192.168.0.30` / `192.168.0.31`  
- **VIPs:** `192.168.0.32` (API), `192.168.0.33` (Web)  
- **DNS recomendado en LBs:** primario `10.17.3.11` (CoreDNS) o DNS LAN; secundario `1.1.1.1` / `8.8.8.8`

### 🛠 kube_network_03 — `10.17.4.0/24` (K3s)

- **Gateway:** `10.17.4.1`  
- Masters: `.21–.23` — Workers: `.24–.26` — Storage: `.27`  
- **DNS:** `8.8.8.8` (primario), `10.17.3.11` (secundario)

### 🧩 kube_network_02 — `10.17.3.0/24` (Infra)

- **Gateway:** `10.17.3.1`  
- Infra: `10.17.3.11` — PostgreSQL: `10.17.3.14`  

> El host `192.168.0.40` enruta entre `br0` y NATs para que LBs alcancen masters/Traefik y servicios internos.

---

## 3️⃣ VIPs y puertos

| VIP           | Puerto(s)  | Servicio                | Backend                                          |
|---------------|------------|-------------------------|--------------------------------------------------|
| 192.168.0.32  | 6443/TCP   | K3s API                  | masters `10.17.4.21–23:6443`                     |
| 192.168.0.33  | 80/443 TCP | Ingress (Traefik)        | workers `10.17.4.24–26` (NodePort/HostPort)      |

---

## 4️⃣ Flujo de tráfico (externo → interno)

1. **Internet** → **Cloudflare** (CDN/WAF/HTTPS)  
2. **Cloudflare DNS** → IP dinámica actualizada por script (DDNS)  
3. **Router físico**  
   - `8080 → 192.168.0.33:80`  
   - `2052 → 192.168.0.33:443`  
4. **HAProxy (LBs)** en `192.168.0.30`/.31 entrega las VIPs:  
   - API `192.168.0.32:6443` → masters `10.17.4.21–23:6443`  
   - Web `192.168.0.33:80/443` → Traefik en workers `10.17.4.24–26`  
5. **Traefik** → Services (ClusterIP) → Pods  

---

## 5️⃣ Diagrama de la arquitectura

🖥️ Host físico: 192.168.0.40 (Rocky Linux + KVM/libvirt)  
┌────────────────────────────────────────────────────┐  
│ Interfaces físicas + br0 (LAN bridge) │  
└────────────────────────────────────────────────────┘  
│  
┌──────┴─────────────┐  
│ │  
🔄 LB1: 192.168.0.30 🔄 LB2: 192.168.0.31  
HAProxy+Keepalived HAProxy+Keepalived  
│ │  
└── VIP API: 192.168.0.32/6443  
VIP Web: 192.168.0.33/80-443  
│  
Router físico (port-forward)  
8080 → VIP Web:80  
2052 → VIP Web:443  
│  
🌐 LAN + NAT internas  

---

## 6️⃣ Bootstrap sin “huevo-gallina”

1. Iniciar `master1` con IP real (`10.17.4.21`)  
2. Unir `master2` y `master3` a `https://10.17.4.21:6443`  
3. Con clúster estable, levantar Keepalived + HAProxy  
4. Cambiar kubeconfig a VIP API (`192.168.0.32`)  

---

## 7️⃣ Seguridad

- 🔐 **VPN WireGuard** para acceso a redes internas  
- 🔐 **HAProxy + Keepalived**: failover y balanceo L4  
- 🔥 **nftables**:  
  - Bloquea API K3s desde Internet  
  - Solo permite tráfico LAN/VPN
