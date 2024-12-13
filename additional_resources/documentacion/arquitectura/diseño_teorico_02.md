Infraestructura y Configuración de Red
1. Arquitectura General
plaintext
Copy code
                        [Usuarios Públicos]  <-- (Acceso HTTPS) --> [Cloudflare CDN]  <-- (Proxy y Cache) -->
      |                                                                   |
      v                                                                   v
+---------------------------+                                  +---------------------------+
| VPS (IP Pública)          |                                  | WireGuard VPN Gateway    |
| Túnel VPN: Seguridad      |                                  | Asegura tráfico interno  |
| Exposición de IP pública  |                                  | IP: 10.17.0.1            |
+---------------------------+                                  +---------------------------+
                                                                     |
                                                                     v
                            WireGuard VPN Gateway         +---------------------------+
                             Servidor Físico              | Red Interna Local (LAN)   |
                             Red LAN Física               | 192.168.0.0/24            |
                                                          +---------------------------+
                                                                     |
                                                                     v
                               +--------------------+--------------------+
                               |                                         |
                               v                                         v
               +---------------------------+         +---------------------------+
               |  Load Balancer 1 (Traefik)|         |  Load Balancer 2 (Traefik)|
               |      IP: 10.17.3.12       |         |      IP: 10.17.3.13       |
               +---------------------------+         +---------------------------+
                                |
                                v
        +---------------------------+---------------------------+
        |                           |                           |
        v                           v                           v
+------------------+   +---------------------------+   +---------------------------+
| Bastion Node     |   |     FreeIPA Node          |   |    PostgreSQL Node        |   
| SSH Access       |   | DNS/Auth (FreeIPA)        |   | Base de Datos             |  
| IP: 192.168.0.20 |   | IP: 10.17.3.11            |   | IP: 10.17.3.14            |   
+------------------+   +---------------------------+   +---------------------------+   
                                |
                                v
        +---------------------------+---------------------------+---------------------------+---------------------------+
        |                           |                           |                           |                           |
        v                           v                           v                           v                           v        
+------------------+   +------------------+   +------------------+   +------------------+   +------------------+  +------------------+
|  Master Node 1   |   |  Master Node 2   |   |  Master Node 3   |   |  Worker Node 1   |   |  Worker Node 2   |  | Storage Node     |
|       (etcd)     |   |       (etcd)     |   |       (etcd)     |   |                  |   |                  |  | Almacenamiento   |
|    10.17.4.21    |   |    10.17.4.22    |   |    10.17.4.23    |   |    10.17.4.24    |   |    10.17.4.25    |  | IP: 10.17.4.27   |
+------------------+   +------------------+   +------------------+   +------------------+   +------------------+  +------------------+
                                |
                                v
                     +------------------+
                     |  Worker Node 3   |
                     |                  |
                     |    10.17.4.26    |
                     +------------------+
2. Configuración de Interfaces de Red
Interfaz	Descripción
enp3s0f0	Interfaz física puenteada a br0.
enp3s0f1	Interfaz adicional sin puente.
enp4s0f0	Interfaz principal para Internet.
enp4s0f1	Interfaz adicional sin puente.
lo	Interfaz loopback (localhost).
3. Configuración de Redes Virtuales
3.1 Red br0 - Bridge Network
hcl
Copy code
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
3.2 Red kube_network_02 - NAT Network
hcl
Copy code
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}
3.3 Red kube_network_03 - NAT Network
hcl
Copy code
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
4. Recursos de Máquinas Virtuales
Nombre de VM	CPU	Memoria (MB)	IP	Dominio	Tamaño de Disco (GB)	Hostname
master1	2	4096	10.17.4.21	master1.cefaslocalserver.com	50	master1
master2	2	4096	10.17.4.22	master2.cefaslocalserver.com	50	master2
master3	2	4096	10.17.4.23	master3.cefaslocalserver.com	50	master3
worker1	2	4096	10.17.4.24	worker1.cefaslocalserver.com	50	worker1
worker2	2	4096	10.17.4.25	worker2.cefaslocalserver.com	50	worker2
worker3	2	4096	10.17.4.26	worker3.cefaslocalserver.com	50	worker3
freeipa1	2	2048	10.17.3.11	freeipa1.cefaslocalserver.com	32	freeipa1
loadbalancer1	2	2048	10.17.3.12	loadbalancer1.cefaslocalserver.com	32	loadbalancer1
postgresql1	2	2048	10.17.3.13	postgresql1.cefaslocalserver.com	32	postgresql1
storage1	2	2048	10.17.3.14	storage1.cefaslocalserver.com	80	storage1
bation1	2	2048	192.168.0.101	bation1.cefaslocalserver.com	80	bation1
Resumen
Conexión interna: Uso de puentes (br0) y redes NAT (kube_network_02, kube_network_03) para una comunicación eficiente.
Balanceadores: Implementación de Traefik con dos nodos para manejar tráfico HTTPS.
VPN: Configuración de un túnel WireGuard para seguridad en la conexión entre la LAN y el VPS.
Segmentación: Redes virtuales basadas en NAT para separar tráfico entre los nodos del clúster Kubernetes.
