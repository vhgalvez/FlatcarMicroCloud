🧩 RESUMEN GENERAL: FlatcarMicroCloud — Arquitectura K3s HA sobre KVM
🖥️ Servidor Físico de Virtualización
Elemento	Detalles
Host físico	192.168.0.40 — Rocky Linux 9.5 con KVM/libvirt
Puente principal	br0 — Adaptador puente (bridge) conectado a la red LAN física
Otras interfaces	Hasta 4 interfaces físicas disponibles (1 usada para LAN + puente)
Virtualización	VMs configuradas con redes puente y NAT (libvirt)

🌐 Red y Direccionamiento
1. Red LAN (Puente br0) — 192.168.0.0/24
Nodo	IP	Rol
infra-cluster	192.168.0.30	Servidor DNS + NTP (CoreDNS + Chrony)
loadbalancer1	192.168.0.11	HAProxy + Keepalived (activo)
loadbalancer2	192.168.0.12	HAProxy + Keepalived (backup)
VIP API	192.168.0.10	Acceso a la API de Kubernetes
VIP Web	192.168.0.14	Acceso HTTP/HTTPS público (web)

➡️ Estas IPs son accesibles dentro de la red local y redireccionadas desde el router físico.

2. Redes NAT Internas (libvirt)
Subred	Función	Componentes principales
10.17.3.0/24	Infraestructura base	PostgreSQL, DNS/NTP (en caso de separar roles)
10.17.4.0/24	Clúster Kubernetes (K3s HA)	Masters, Workers, Storage (Longhorn + NFS)
10.17.5.0/24	Servicios backend (opcional)	PostgreSQL dedicado, microservicios externos

➡️ NAT proporciona aislamiento. El tráfico entre redes NAT y LAN se controla desde el host físico con nftables.

☸️ Clúster Kubernetes (K3s HA)
Rol	IPs	Descripción
Masters	10.17.4.21–23	K3s con etcd en alta disponibilidad
Workers	10.17.4.24–26	Nodos para despliegue de aplicaciones
Storage	10.17.4.27	NFS + Longhorn para persistencia

➡️ Tráfico hacia los servicios del clúster entra desde los balanceadores por VIP 192.168.0.14.

🗄️ Servicios Internos
Servicio	Nodo	IP	Detalles
PostgreSQL	postgresql1	10.17.3.14	Base de datos para apps y microservicios
DNS/NTP	infra-cluster	192.168.0.30	Resuelve dominios internos y sincroniza reloj

🛡️ Seguridad y Accesos
🔐 VPN
WireGuard desde un VPS o cliente remoto

Permite acceder a toda la red privada (API de Kubernetes, dashboard, etc.)

API no se expone directamente al público

🔐 HAProxy + Keepalived
VIP	Puerto	Servicio expuesto
192.168.0.10	6443	API Kubernetes (solo por VPN o LAN)
192.168.0.14	80/443	Web pública (Traefik / Ingress)

🔥 Firewall (nftables en el host físico)
Permite tráfico entrante solo desde VPN o LAN para puertos sensibles (como 6443).

Bloquea cualquier acceso desde Internet a la API Kubernetes.

🌍 Router Físico
Reglas de redirección
8080 → 192.168.0.14:80
2052 → 192.168.0.14:443

➡️ Esto permite acceder desde fuera al sitio web Ingress (Traefik, apps web).
➡️ No se expone el puerto 6443 (API Kubernetes) directamente, solo accesible por VPN/LAN.

🧠 Ventajas del diseño actual
Ventaja	Explicación
🛡️ Seguridad fuerte	API no expuesta directamente, firewall + VPN
🔄 Alta disponibilidad (HA)	K3s con etcd HA, HAProxy con Keepalived
🧩 Modularidad y escalabilidad	Puedes añadir más nodos fácilmente
🧠 Separación de roles y redes	Balanceadores, clúster y DB en redes distintas
🧪 Entorno realista para aprendizaje	Reproduce topologías de producción en casa
🔗 Acceso remoto controlado	VPN + DNS interno (CoreDNS)
🔧 Automatización preparada	Usas Ansible + Terraform para infraestructura