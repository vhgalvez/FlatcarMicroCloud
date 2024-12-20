Descripción General
Router Físico (Fibra Óptica):

Proporciona acceso a internet y hace de servidor DHCP para la red física.
Configura la IP del pfSense WAN de forma estática dentro del rango DHCP del router físico.
Servidor Físico (Rocky Linux, KVM/Libvirt):

Cuenta con 4 interfaces de red físicas:
2 interfaces dedicadas a pfSense:
WAN → enp3s0f0 → br0 (puente WAN).
LAN → enp3s0f1 → br1 (puente LAN).
2 interfaces para servicios adicionales en el servidor físico.
pfSense (VM):

Gestiona la red: filtra, enruta y asegura el tráfico.
Conecta las redes WAN y LAN internas, y añade rutas estáticas hacia las subredes virtualizadas.
Subredes Segmentadas:

Redes dedicadas para cada servicio: LAN física, servicios internos, Kubernetes, seguridad, y acceso remoto mediante VPN.
Mapa de Infraestructura de Red


plaintext


+----------------------------------+                               
                     |    Usuarios Públicos            |                                
                     +----------------------------------+                               
                                     |                                                   
                                     | HTTPS (80/443)                                     
                                     v                                                   
                     +----------------------------------+                                
                     |       Cloudflare CDN            |                                
                     |     (Proxy y Cache Público)     |                                
                     +----------------------------------+                               
                                     |                                                   
                                     v                                                   
                     +----------------------------------+                                
                     |           VPS (VPN)             |                                
                     |   Exposición IP Pública (XXX.X) |                                
                     +----------------------------------+                               
                                     |                                                   
            +============= WireGuard VPN Gateway =============+                         
            |                                                 |                         
            v                                                 v                         
+-----------------------+                          +----------------------------+        
| WireGuard VPN Gateway |                          |  Red LAN Física (br1)      |        
| IP: 10.17.0.1         |                          |  Subred: 192.168.1.0/24    |        
+-----------------------+                          |  Gateway: 192.168.1.1      |        
            |                                      +----------------------------+        
            |                                                    |                    
            |                                                    v                    
+----------------------+                          +--------------------------------+    
| Router Físico (DHCP) |                          | Servidor Físico (Rocky Linux)  |    
| Fibra Óptica         |                          |  4 Interfaces de Red:          |    
| DHCP: 192.168.0.0/24 |                          |  - WAN (br0: enp3s0f0)         |    
+----------------------+                          |  - LAN (br1: enp3s0f1)         |    
            |                                      +--------------------------------+    
            |                                                    |                    
            v                                                    v                    
+----------------------+                          +--------------------------------+    
| pfSense VM           |                          | Redes Virtualizadas (KVM)      |    
| Firewall Principal   |                          |                                |    
| WAN: 192.168.0.200   |                          |  1. Cluster Interno (10.17.3.x)|    
| LAN: 192.168.1.1     |                          |  2. Cluster Kubernetes (10.17.4|    
+----------------------+                          |  3. Gestión y Seguridad (10.5) |    
            |                                                    |                    
            |                                                    v                    
            +============ Rutas Internas ===========+                                  
                         |                          |                                
                         v                          v                                
+----------------------+       +----------------------+      +----------------------+  
| Bastion Node         |       | FreeIPA Node         |      | PostgreSQL Node       |  
| Seguridad: 10.17.5.2 |       | DNS/Auth: 10.17.3.11 |      | Base de Datos: 10.3.14|  
+----------------------+       +----------------------+      +----------------------+  
                         |                           |                                
                         v                           v                                
        +--------------------------+       +---------------------------+              
        | Master Node 1 (etcd)     |       | Master Node 2 (etcd)      |              
        | IP: 10.17.4.21           |       | IP: 10.17.4.22            |              
        +--------------------------+       +---------------------------+              
                         |                           |                                
                         v                           v                                
        +--------------------------+       +---------------------------+              
        | Worker Node 1            |       | Storage Node              |              
        | IP: 10.17.4.24           |       | IP: 10.17.4.27            |              
        +--------------------------+       +---------------------------+              




Explicación por Componentes
Router Físico (Fibra Óptica):

IP: 192.168.0.1.
Proporciona internet y asigna direcciones IP a través de DHCP.
Servidor Físico:

Sistema operativo: Rocky Linux.
KVM/Libvirt para la virtualización.
Interfaces de red:
enp3s0f0: WAN, puenteado a br0.
enp3s0f1: LAN, puenteado a br1.
Puente br0 (WAN): Conecta pfSense a internet.
Puente br1 (LAN): Proporciona acceso a la red interna 192.168.1.0/24.
pfSense VM:

WAN: 192.168.0.10 (conectado a br0).
LAN: 192.168.1.1 (conectado a br1).
Funciones: Firewall, VPN WireGuard, y gestor de rutas estáticas para redes virtuales.
WireGuard VPN:

Red: 10.17.0.0/24.
Gateway: 10.17.0.1.
Proporciona acceso seguro a todas las redes internas desde fuera de la infraestructura.
Subredes Virtuales:

10.17.3.0/24: Servicios críticos (FreeIPA, PostgreSQL, Traefik).
10.17.4.0/24: Kubernetes (Masters, Workers, Storage).
10.17.5.0/24: Seguridad y gestión (Bastion Node).
Traefik Load Balancers:

Balancean el tráfico HTTPS hacia los servicios internos.
Kubernetes Cluster:

Nodos Masters (etcd) y Workers con almacenamiento distribuido.
Flujo del Tráfico
Usuarios Públicos → Cloudflare CDN → pfSense WAN → Load Balancers (Traefik).
VPN WireGuard: Usuarios remotos conectan a través del gateway 10.17.0.1.
pfSense enruta tráfico a las redes internas:
LAN: 192.168.1.0/24.
Servicios: 10.17.3.0/24.
Kubernetes: 10.17.4.0/24.
Conclusión
Esta infraestructura:

Optimiza el flujo de tráfico segmentado.
Asegura la red con pfSense y VPN WireGuard.
Escala con virtualización KVM/Libvirt y clúster Kubernetes.
Facilita la gestión centralizada mediante Bastion Node y FreeIPA