📡 Arquitectura de FlatcarMicroCloud (Self-Hosting con Dominio Público)
🌍 Infraestructura Global y Accesos Externos
lua
Copiar
Editar
[Usuarios Públicos]
       │
       ▼
+-------------------+
| Cloudflare CDN    | ◄── Proxy DNS (sin usar CDN)
| (dominio.com)     |
+-------------------+
       │
       ▼
+-----------------------------+
| Router ISP (IP dinámica)   |
| Red doméstica 192.168.0.x  |
| NAT + Port Forwarding      |
| Puertos 80, 443, 51820     |
+-----------------------------+
       │
       ▼
+-----------------------------------------+
| Servidor Físico (ProLiant DL380 G7)     |
| WireGuard VPN (51820/UDP)               |
| Interfaz pública: 192.168.0.19          |
+-----------------------------------------+
       │
       ▼
+------------------------------------------+
| KVM + Bridges para clúster K3s           |
| Puentes: br0 (web), br-api (API K8s)     |
| Red NAT para gestión y salida a internet |
+------------------------------------------+
🔐 Separación de Tráfico y Balanceo de Cargas
Tipo de Tráfico	VIP Asignada	Función
Kubernetes API (6443)	10.17.5.10	Acceso estable al clúster (kubectl, etcd, plane)
Ingress HTTP/HTTPS	10.17.5.30	Entrada para servicios web expuestos con Traefik
VPN privada	192.168.0.19:51820	Acceso administrativo seguro vía WireGuard

Las VIPs son gestionadas por HAProxy + Keepalived, flotando entre tres nodos balanceadores.

🧠 Servidor Físico Central
Modelo: HP ProLiant DL380 G7

CPU: Intel Xeon X5650 (24 cores)

RAM: 35 GB

Discos: 1.5 TB (principal), 3.0 TB (secundario)

Sistema base: Rocky Linux + KVM/libvirt

Red física: Switch TP-Link LS1008G + Router Fibra 600/600 Mbps

Interfaces de red:
Interfaz	Uso
enp3s0f0	Bridge br-api (API K8s)
enp3s0f1	Libre
enp4s0f0	Bridge br0 (web HTTPS)
enp4s0f1	Acceso administración
lo	Loopback

☸️ Clúster Kubernetes (K3s HA)
Nodo	IP	Función
master1	10.17.4.21	Control Plane + etcd (bootstrap)
master2	10.17.4.22	Control Plane + etcd
master3	10.17.4.23	Control Plane + etcd
worker1	10.17.4.24	Apps + Traefik
worker2	10.17.4.25	Apps + Traefik
worker3	10.17.4.26	Apps + Traefik
storage1	10.17.4.27	NFS + Longhorn

⚙️ Balanceadores y VIPs
Nodo	IP	Rol
k8s-api-lb	10.17.5.20	Nodo con VIPs por defecto
loadbalancer1	10.17.3.12	Respaldo 1 (Traefik/API)
loadbalancer2	10.17.3.13	Respaldo 2 (Traefik/API)

📦 Almacenamiento Persistente
Longhorn (RWO): Microservicios, Prometheus, Grafana

NFS (RWX): PostgreSQL, volumen compartido /srv/nfs/shared

🧰 Seguridad y DNS
Componente	Función
WireGuard	Acceso administrativo externo
nftables	Firewall local en servidor físico
CoreDNS	DNS interno en VM infra-cluster (10.17.3.11)
Cloudflare	Proxy DNS, delegación desde Namecheap (sin CDN)

🧪 Configuración Cloudflare con IP Dinámica
Para no pagar por servicios premium, se configura solo DNS en Cloudflare con:

Un A Record lab.dominio.com apuntando a la IP pública.

Un script en el servidor físico que:

Obtiene la IP pública con curl ifconfig.me.

Llama a la API de Cloudflare con token para actualizar el A Record.

Se ejecuta como cron cada 5-10 minutos.

Esto mantiene el dominio sincronizado con la IP dinámica del ISP.

🔁 Flujo de Tráfico Simplificado
nginx
Copiar
Editar
Cliente Web → dominio.com
        ↓
Cloudflare DNS → IP Pública (Router)
        ↓
Port Forwarding: 80/443 → VIP: 10.17.5.30
        ↓
HAProxy + Keepalived → Traefik (Ingress interno)
        ↓
K8s Services y Pods

Admin VPN (WireGuard) → 192.168.0.19:51820 → Acceso total privado
✅ Ventajas de esta Arquitectura
💰 Alojamiento sin coste en servidores propios (sin VPS)

🔒 Acceso seguro con WireGuard

🌍 Exposición pública vía dominio + Cloudflare (sin CDN)

🛠️ Despliegue modular 100% automatizado con Ansible

📈 Escalable con almacenamiento distribuido y nodos adicionales

📦 Listo para CI/CD con Jenkins, ArgoCD y secretos cifrados (Sealed Secrets)