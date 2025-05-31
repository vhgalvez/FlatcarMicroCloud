🧠 Resumen General de la Infraestructura
Host físico: virtualizacion-server

SO: Rocky Linux 9.5

RAM: 35 GB

CPU: 2 × Intel Xeon X5650 (24 hilos en total)

Almacenamiento:

/: 70 GB

/var/lib/libvirt/images: 500 GB

/home: 3,1 TB

Hypervisor: libvirt con KVM

Firewall activo: nftables

Tipo de red: Redes bridge y NAT con múltiples interfaces físicas y virtuales.

🕸️ Topología de Red
🌐 Interfaces físicas
Interfaz	IP	Rol
enp4s0f0	192.168.0.21	Principal de salida (gateway por defecto)
enp3s0f1	192.168.0.28	Acceso LAN adicional
enp4s0f1	192.168.0.29	Acceso LAN adicional
br0	192.168.0.20	Bridge principal para VMs con acceso LAN

🔁 Bridges virtuales (libvirt)
Bridge	IP / Subred	Función
virbr_kube02	10.17.3.1/24	Red privada para VMs de tipo infra
virbr_kube03	10.17.4.1/24	Red privada para VMs worker/master
virbr0	192.168.122.1/24	NAT default libvirt (no usada activamente)
docker0	172.17.0.1/16	Interfaz Docker (inactiva)

🧱 Firewall nftables
Política por defecto: DROP

Permite:

Tráfico entrante en puertos específicos (22, 80, 443, 8080, etc.)

Tráfico hacia el VIP del API Server Kubernetes: 10.17.5.10:6443

Tráfico entre VMs dentro de 10.17.0.0/16

Tráfico desde/entre bridges virtuales y físicos (br0, virbr_kube02, virbr_kube03)

Masquerade/NAT de salida hacia Internet en interfaces físicas.

🧩 Máquinas Virtuales Activas (13 VMs)
ID	Nombre	Función	Red Asignada
2	k8s-api-lb.socialdevs.site	API Load Balancer HAProxy	br0 + VIP (10.17.x)
3	infra-cluster	DNS, NTP, Core Services	virbr_kube02
4	load_balancer2	HAProxy secundario	br0 + virbr_kube03
5	postgresql1	Base de datos centralizada	virbr_kube02
6	load_balancer1	HAProxy primario	br0 + virbr_kube03
7	master1	Nodo Master Kubernetes	virbr_kube03
8	master2	Nodo Master Kubernetes	virbr_kube03
9	worker3	Worker Kubernetes	virbr_kube03
10	worker2	Worker Kubernetes	virbr_kube03
11	worker1	Worker Kubernetes	virbr_kube03
12	master3	Nodo Master Kubernetes	virbr_kube03
13	storage1	Longhorn/NFS Storage	virbr_kube02

🧬 VIPs y Clúster Kubernetes
VIP del API Server: 10.17.5.10:6443

VIP Traefik / servicios web: 192.168.0.30

K3s en modo HA con múltiples masters (master1, master2, master3) y workers (worker1 a worker3)

🌍 Routing & Gateway
Default gateway: 192.168.0.1 en múltiples interfaces.

Rutas locales:

10.17.3.0/24 → virbr_kube02

10.17.4.0/24 → virbr_kube03

192.168.0.0/24 → todas las interfaces físicas + br0

🧩 Observaciones Técnicas
Tienes múltiples interfaces físicas activas con rutas redundantes: podrías optimizar tráfico deshabilitando rutas en enp3s0f1 y enp4s0f1 si no se usan.

El firewall está correctamente configurado para separar acceso LAN, tráfico K8s y servicios expuestos.

Todas las VMs relevantes tienen acceso a NAT y LAN, lo cual permite integración completa y acceso externo si es necesario.

Longhorn y PostgreSQL están en redes privadas aisladas (buen diseño para seguridad).

DNS, NTP, y otros servicios internos están centralizados en infra-cluster.

