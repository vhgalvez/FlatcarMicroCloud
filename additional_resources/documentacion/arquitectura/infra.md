🧩 FlatcarMicroCloud — Arquitectura K3s HA sobre KVM

                 🖥️ Host físico: 192.168.0.40 (Rocky Linux + KVM/libvirt)
                 ┌────────────────────────────────────────────────────┐
                 │          Interfaces físicas + br0 (LAN bridge)     │
                 └────────────────────────────────────────────────────┘
                                 │
               ┌────────────────┴─────────────────────┐
               │                                      │
          🔄 LoadBalancer 1                       🔁 LoadBalancer 2
     (192.168.0.11 - HAProxy + Keepalived)   (192.168.0.12 - HAProxy + Keepalived)
               │                                      │
               └────── VIP: 192.168.0.10/6443 (API) ──┘
                       VIP: 192.168.0.14/80-443 (Web)

                                 │
                    🔄 Redirección desde router físico
                    [8080 → 192.168.0.14:80]
                    [2052 → 192.168.0.14:443]

╭────────────────────────────────────────────────────────────────────────────╮
│                         🌐 Red LAN: 192.168.0.0/24                         │
│                                                                            │
│ infra-cluster: 192.168.0.30 → CoreDNS + Chrony                             │
│                                                                            │

╰────────────────────────────────────────────────────────────────────────────╯

╭────────────────────────────────────────────────────────────────────────────╮
│              🔐 Redes NAT Internas (libvirt): Seguridad y aislamiento      │
│────────────────────────────────────────────────────────────────────────────│
│ 🧱 10.17.3.0/24 — Infraestructura base                                     │
│    └─ postgresql1: 10.17.3.14 → Base de datos                              │
│    └─ infra-cluster (si replica roles DNS/NTP)                             │
│    └─ PostgreSQL dedicado, microservicios, etc.                           │
│                                                                            │
│ ☸️ 10.17.4.0/24 — Clúster Kubernetes (K3s HA)                              │
│    ├─ Masters:   10.17.4.21–23 (etcd + control-plane)                      │
│    ├─ Workers:   10.17.4.24–26 (aplicaciones)                              │
│    └─ Storage:   10.17.4.27     (NFS + Longhorn)                           │
│                                                                                       │
╰────────────────────────────────────────────────────────────────────────────╯

🔒 Seguridad y Accesos
──────────────────────────────────────────────────────────────
- 🔐 VPN (WireGuard): acceso seguro a la red privada desde VPS o cliente
- 🔐 HAProxy + Keepalived: balanceo + failover de API y Web
- 🔥 nftables: firewall en host físico
    - Solo permite tráfico desde VPN/LAN
    - Bloquea acceso directo a API Kubernetes desde Internet

🌍 Acceso externo
──────────────────────────────────────────────────────────────
- La API de Kubernetes (6443) solo es accesible por VPN o LAN
- El tráfico web (Traefik, apps) entra por 8080 y 2052 al VIP 192.168.0.14

🧠 Ventajas del diseño
──────────────────────────────────────────────────────────────
🛡️  Seguridad fuerte         — API no expuesta + firewall + VPN
🔄  Alta disponibilidad      — HA con etcd, HAProxy, Keepalived
🧩  Modular y escalable      — Añadir nodos fácilmente
🔌  Redes separadas          — Mejor aislamiento y rendimiento
🧪  Simulación realista      — Entorno tipo producción en casa
🔧  Automatización lista     — Soporte para Ansible + Terraform
