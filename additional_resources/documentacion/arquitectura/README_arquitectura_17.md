Actualización Final de la Infraestructura Híbrida FlatcarMicroCloud
🔁 Balanceadores de Carga (LAN - Bridge br0)
Rol	Hostname	IP LAN	Función Técnica
Principal	load_balancer1	192.168.0.12	HAProxy + Keepalived (VIPs: API/Web) – Activo
Backup	load_balancer2	192.168.0.13	HAProxy + Keepalived (VIPs: API/Web) – Backup

🎯 VIPs asignadas por Keepalived (LAN pública)
IP Virtual	Descripción	Servicio
192.168.0.10	IP virtual de la API de Kubernetes	Puerto 6443
192.168.0.14	IP virtual para HTTP/HTTPS públicos	Puertos 80/443

🌐 Red NAT 10.17.3.0/24 – Infraestructura Interna
Rol	Hostname	IP Interna	Función Técnica
Infraestructura	infra-cluster	10.17.3.11	DNS (CoreDNS), NTP (Chrony), Gateway a redes 10.x
PostgreSQL	postgresql1	10.17.3.14	Base de datos persistente para microservicios

☸️ Clúster Kubernetes (Red NAT 10.17.4.0/24)
Rol	Hostname	IP Interna	Función Técnica
Master Node	master1	10.17.4.21	K3s control-plane + etcd
Master Node	master2	10.17.4.22	K3s control-plane + etcd
Master Node	master3	10.17.4.23	K3s control-plane + etcd
Worker Node	worker1	10.17.4.24	K3s worker
Worker Node	worker2	10.17.4.25	K3s worker
Worker Node	worker3	10.17.4.26	K3s worker
Almacenamiento	storage1	10.17.4.27	Longhorn + NFS

🔀 Rutas de Conectividad
Los balanceadores en LAN (192.168.0.12 y .13) tienen rutas estáticas a 10.17.3.0/24 y 10.17.4.0/24 vía 192.168.0.11 (o simplemente por NAT en infra-cluster si no hay rutas).

infra-cluster hace de router interno entre redes 10.17.3, 10.17.4, y la LAN pública (192.168.0.x), usando nftables.

El tráfico entre clúster, PostgreSQL y balanceadores fluye sin restricciones mediante NAT o rutas explícitas.