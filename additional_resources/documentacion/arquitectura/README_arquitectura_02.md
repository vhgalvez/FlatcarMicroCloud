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
| Internet con IP dinámica   |
+----------------------------+
       │
       ▼
+-----------------------------+
| Router ISP (LAN: 192.198.0.x)|
| NAT + Port Forwarding       |
| Puertos 80 y 443 abiertos   |
+-----------------------------+
       │
       ▼
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

### 🧩 Red Física y Conectividad del Servidor

**🖥 Servidor Central (Bare Metal):**

* Modelo: ProLiant DL380 G7
* CPU: Intel Xeon X5650 (24 cores) @ 2.666GHz
* RAM: 35 GB
* Almacenamiento: 1.5 TB (principal), 3.0 TB (secundario)

**🔌 Conectividad Física y Dispositivos de Red:**

* Switch: TP-Link LS1008G (8 puertos Gigabit no administrados)
* Router ISP: Fibra óptica, IP pública, 600 Mbps subida/bajada
* VPN: WireGuard instalado para acceso seguro
* Seguridad adicional: nftables para reglas de firewall

**🌐 Interfaces de Red del Servidor:**

| Interfaz | Estado    | Uso Sugerido                |
| -------- | --------- | --------------------------- |
| enp3s0f0 | Conectada | Bridge para tráfico API     |
| enp3s0f1 | Conectada |                             |
| enp4s0f0 | Conectada | Bridge para tráfico web     |
| enp4s0f1 | Conectada | Administración/Acceso local |
| lo       | Loopback  | Interno del sistema         |

> Estas interfaces están conectadas al switch TP-Link y al router de fibra óptica, operando bajo DHCP, en la red LAN 192.198.0.x, facilitando el enrutamiento de tráfico interno y externo, así como el aislamiento de tráfico por roles usando bridges virtuales con KVM.

**🌉 Red Virtual (KVM/libvirt):**

* Red NAT para gestión de tráfico desde el servidor
* Red Bridge para interconectar VMs con red real
* Bridges configurados: `br0`, `br1`, y `br-api` (puente de tráfico API)

**🌐 Dirección IP del puente del tráfico API:**

* Bridge `br-api` asignado a HAProxy API: `192.198.0.30` (IP fija LAN)

### 🖧 Tabla de Nodos del Clúster

| Hostname      | IP         | Función                    | CPU | RAM (MB) | Disco (GB) |
| ------------- | ---------- | -------------------------- | --- | -------- | ---------- |
| master1       | 10.17.4.21 | Control Plane Kubernetes   | 2   | 4096     | 50         |
| master2       | 10.17.4.22 | Control Plane Kubernetes   | 2   | 4096     | 50         |
| master3       | 10.17.4.23 | Control Plane Kubernetes   | 2   | 4096     | 50         |
| worker1       | 10.17.4.24 | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| worker2       | 10.17.4.25 | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| worker3       | 10.17.4.26 | Nodo Worker Kubernetes     | 2   | 4096     | 50         |
| storage1      | 10.17.4.27 | NFS + Longhorn Storage     | 2   | 2048     | 80         |
| infra-cluster | 10.17.3.11 | DNS coredns / ntp  Chrony  | 2   | 2048     | 32         |
| loadbalancer1 | 10.17.3.12 | Ingress Controller Traefik | 2   | 2048     | 32         |
| loadbalancer2 | 10.17.3.13 | Ingress Controller Traefik | 2   | 2048     | 32         |
| postgresql1   | 10.17.3.14 | Base de datos PostgreSQL   | 2   | 2048     | 32         |
| k8s-api-lb    | 10.17.5.10 | VIP HAProxy + Keepalived   | 2   | 2048     | 80         |

---

### ✅ Características Clave

* Self-hosting desde servidor bare metal con IP pública o redirección por Cloudflare
* Automatización de DNS dinámico mediante script con API de Cloudflare
* Modo dual: dominio público (Let’s Encrypt) y sin dominio (certificados autofirmados)
* Separación clara de tráfico API (6443) y Web (80/443) mediante VIPs
* Traefik como Ingress Controller desplegado como Deployment en el clúster
* Posibilidad de migrar certificados y configuración a PVCs tras instalación de Longhorn
* Seguridad robusta con WireGuard, nftables y gestión de accesos externa
* Arquitectura modular, automatizada completamente con Terraform y Ansible

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












Actualización Automática de IP Pública en Cloudflare (DNS Dinámico)
🎯 Objetivo
Permitir que tu dominio público (ej: example.com) apunte siempre a la IP pública actual de tu red doméstica, incluso si tu ISP cambia dinámicamente tu IP. Esto garantiza que el acceso externo a tus servicios (expuestos vía Cloudflare y HAProxy) nunca se rompa.

🧰 Componentes Involucrados
🧠 Cloudflare API: permite actualizar un A record del dominio de forma programática.

🧾 Token API de Cloudflare: con permisos mínimos (editar zona DNS).

📜 Script Bash: detecta cambios en la IP pública y llama a Cloudflare para actualizar el DNS.

⏱️ Cron job: ejecuta el script automáticamente cada X minutos.

⚙️ Flujo de Implementación
Obtener Token de Cloudflare:

Ve a https://dash.cloudflare.com/profile/api-tokens.

Crea un token personalizado con:

Permisos: Zone → DNS → Edit

Zona: Tu dominio (example.com)

Instalar Dependencias:
Asegúrate de tener curl, jq y cron en tu servidor físico (host bare-metal):

bash
Copiar
Editar
sudo apt install curl jq cron -y   # o en Fedora/Rocky: dnf install ...
Script Bash (update-cloudflare-dns.sh):
Guarda este archivo en /usr/local/bin/update-cloudflare-dns.sh y hazlo ejecutable:

bash
Copiar
Editar
chmod +x /usr/local/bin/update-cloudflare-dns.sh
bash
Copiar
Editar
#!/bin/bash

# Configura tus datos
ZONE_ID="xxxxxxxxxxxxxxxxxxxxxxxx"   # ID de tu zona (dominio)
RECORD_ID="yyyyyyyyyyyyyyyyyyyy"     # ID del A record a actualizar
TOKEN="YOUR_CLOUDFLARE_API_TOKEN"
RECORD_NAME="example.com"

# Detecta IP pública actual
CURRENT_IP=$(curl -s https://api.ipify.org)
echo "IP actual detectada: $CURRENT_IP"

# IP actualmente configurada en Cloudflare
CF_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | jq -r .result.content)

if [ "$CURRENT_IP" == "$CF_IP" ]; then
    echo "La IP no ha cambiado ($CURRENT_IP). No se actualiza nada."
    exit 0
fi

# Actualiza el A Record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":120,\"proxied\":true}" \
  | jq

echo "IP de Cloudflare actualizada a $CURRENT_IP"
Programar la Tarea con Cron:
Ejecutar el script cada 5 minutos:

bash
Copiar
Editar
crontab -e
Añade esta línea:

pgsql
Copiar
Editar
*/5 * * * * /usr/local/bin/update-cloudflare-dns.sh >> /var/log/cloudflare-update.log 2>&1
✅ Resultado Integrado en FlatcarMicroCloud
Tu dominio público example.com apuntará siempre a la IP pública del router, permitiendo el acceso a los servicios de tu arquitectura:

css
Copiar
Editar
[Internet] → [Cloudflare A Record dinámico] → [IP Pública del Router ISP]
→ [Port forwarding 80/443] → [br-api: 192.198.0.30] → [HAProxy VIP] → [Traefik / Kubernetes]
