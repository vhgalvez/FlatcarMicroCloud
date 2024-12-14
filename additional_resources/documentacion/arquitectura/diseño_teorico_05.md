Resumen Teórico del Tunel entre el Servidor Físico, VPS, CDN, y Controladores Ingress
Este esquema conecta usuarios externos a los servicios internos del clúster Kubernetes mediante una combinación de CDN (Cloudflare), VPS con IP pública, y controladores de Ingress balanceados con Traefik. A continuación, se describe el flujo del tráfico y los roles de cada componente actualizado al esquema.

Componentes Involucrados
Usuarios Públicos:

Acceden a través de HTTPS (https://miservicio.com).
No tienen acceso directo al VPS o la infraestructura interna.
CDN (Cloudflare):

Actúa como proxy inverso y distribuidor del tráfico HTTPS.
Ofrece protección contra DDoS, cacheo de contenido, y balanceo global.
VPS con IP Pública:

Túnel VPN (WireGuard) para conectar al servidor físico.
Recibe el tráfico HTTPS de la CDN y lo redirige al servidor físico mediante la VPN.
Servidor Físico (LAN):

Termina el túnel VPN.
Distribuye el tráfico HTTPS a los balanceadores de carga internos (Traefik).
Red Interna: 192.168.0.0/24 para gestión local y redes NAT (10.17.3.0/24, 10.17.4.0/24) para Kubernetes.
Controladores de Ingress (Traefik):

Dos balanceadores (10.17.3.12, 10.17.3.13) distribuyen el tráfico interno hacia los servicios de Kubernetes.
Aseguran alta disponibilidad para el tráfico HTTP/HTTPS.
Clúster Kubernetes:

Nodos maestros (10.17.4.21, 10.17.4.22, 10.17.4.23) y workers (10.17.4.24, etc.) ejecutan aplicaciones y microservicios.
Flujo del Tráfico
Usuarios Públicos a la CDN (Cloudflare):

Todo el tráfico HTTPS es gestionado por Cloudflare, protegiendo la infraestructura contra ataques y mejorando la disponibilidad global.
CDN al VPS:

El tráfico HTTPS (puertos 80/443) es redirigido desde la CDN al VPS usando la IP pública del VPS.
VPS al Servidor Físico (Túnel VPN):

El VPS reenvía el tráfico recibido a través de un túnel WireGuard seguro hacia el servidor físico.
Dentro del túnel, todo el tráfico está cifrado, garantizando la seguridad de los datos.
Servidor Físico a los Controladores Ingress:

El servidor físico distribuye el tráfico HTTPS recibido del túnel VPN hacia los controladores Ingress (Traefik), en la red NAT 10.17.3.0/24.
Ingress a los Servicios Kubernetes:

Los controladores Ingress redirigen el tráfico a los servicios internos en los nodos Kubernetes (10.17.4.0/24), balanceando la carga entre los nodos workers.
Esquema Actualizado
plaintext
Copy code
[Usuarios Públicos]
      |
      | HTTPS (80/443)
      v
[CDN (Cloudflare)]
      |
      | HTTPS
      v
[VPS con IP Pública]
      |
      | VPN (WireGuard)
      v
[Servidor Físico]
      |
      | Red NAT
      v
[Controladores Ingress (Traefik)]
      |
      | Servicios Internos
      v
[Clúster Kubernetes]
Roles de Cada Componente
CDN (Cloudflare):

Proxy inverso que protege contra ataques y proporciona acceso HTTPS público.
Balancea el tráfico a nivel global y lo redirige al VPS.
VPS con IP Pública:

Termina las conexiones HTTPS recibidas desde la CDN.
Crea un túnel seguro con el servidor físico usando WireGuard.
Servidor Físico:

Termina el túnel VPN.
Reenvía el tráfico HTTPS a los balanceadores Traefik internos.
Controladores Ingress (Traefik):

Balancean el tráfico HTTP/HTTPS dentro del clúster Kubernetes.
Distribuyen el tráfico hacia los servicios internos según las reglas definidas.
Clúster Kubernetes:

Ejecuta las aplicaciones y microservicios que procesan las solicitudes de los usuarios externos.
Beneficios del Esquema
Seguridad:

El túnel VPN cifra todo el tráfico entre el VPS y el servidor físico.
La CDN protege contra ataques DDoS y asegura el acceso HTTPS.
Distribución de Carga:

Los controladores Ingress balancean el tráfico dentro del clúster.
Alta Disponibilidad:

La redundancia en los controladores Ingress asegura que el tráfico fluya incluso si uno falla.
Aislamiento:

La red interna del clúster Kubernetes permanece inaccesible desde el exterior.
¿Qué más se puede configurar?
Firewall:

Configurar reglas estrictas en el VPS y el servidor físico para limitar el tráfico al túnel VPN y las redes NAT.
Monitorización:

Usar Prometheus y Grafana para visualizar el tráfico y detectar problemas.
Pruebas de Conectividad:

Verificar las rutas del túnel VPN y el balanceo de carga interno.

_
Configuración del Proyecto: Interfaces, IPs, Roles y Redes
Interfaz Física	Red Asociada	Configuración IP	Rol/Comentarios
enp3s0f0	WAN	Fija: 192.168.100.2	Conexión principal del servidor físico a Internet y al VPS. Permite el acceso desde fuera mediante el túnel VPN (WireGuard) y tráfico general (salida WAN).
enp3s0f1	WAN (opcional)	Bonding con enp3s0f0	Configurada como parte de bond0 para redundancia o balanceo de carga.
bond0	WAN	Fija: 192.168.100.2	Interface lógica que combina enp3s0f0 y enp3s0f1. Usada para conexión a Internet y al VPS, con mayor ancho de banda y failover.
enp4s0f0	LAN	Fija: 192.168.0.1	Conexión interna para redes NAT de KVM (kube_network_02, kube_network_03). Funciona como gateway para las máquinas virtuales.
enp4s0f1	Almacenamiento	Fija: 192.168.1.1	Dedicada al tráfico de almacenamiento (NFS/Longhorn). Separa el tráfico de almacenamiento del resto de las operaciones para evitar cuellos de botella.
lo	Loopback	127.0.0.1	Tráfico interno en el servidor físico. Usado para servicios locales y pruebas.
Redes Virtuales Configuradas (NAT en KVM)
Red Virtual (NAT)	Nodos/VMs Asociados	Rango IP	Rol del Nodo/Red
kube_network_02	freeipa1, loadbalancer1, loadbalancer2, postgresql1	10.17.3.0/24	Red NAT para servicios internos (DNS, balanceadores, base de datos).
kube_network_03	master1, worker1, worker2, worker3, storage1	10.17.4.0/24	Red NAT para nodos del clúster Kubernetes (Masters, Workers) y almacenamiento compartido (NFS/Longhorn).
br0_network	bastion1	10.17.5.0/24	Red dedicada para el nodo Bastion. Proporciona gestión y seguridad centralizada para el clúster.
Roles de las Máquinas Virtuales
VM/Nodo	Red Virtual	IP Fija	Rol
freeipa1	kube_network_02	10.17.3.11	Servidor DNS y autenticación centralizada.
loadbalancer1	kube_network_02	10.17.3.12	Balanceador de carga (Traefik).
loadbalancer2	kube_network_02	10.17.3.13	Balanceador de carga secundario para alta disponibilidad.
postgresql1	kube_network_02	10.17.3.14	Base de datos para aplicaciones desplegadas en el clúster.
master1	kube_network_03	10.17.4.21	Nodo maestro 1 del clúster Kubernetes (plano de control).
worker1	kube_network_03	10.17.4.24	Nodo Worker para la ejecución de microservicios y aplicaciones.
worker2	kube_network_03	10.17.4.25	Nodo Worker secundario para la ejecución de microservicios y aplicaciones.
worker3	kube_network_03	10.17.4.26	Nodo Worker adicional para escalabilidad horizontal.
storage1	kube_network_03	10.17.4.27	Nodo dedicado al almacenamiento compartido (NFS/Longhorn).
bastion1	br0_network	10.17.5.2	Nodo de gestión y seguridad centralizada. Administra el acceso a las redes internas y al clúster.
Puertas de Enlace (Gateways)
Red Virtual (NAT)	Gateway del Servidor Físico	Comentarios
kube_network_02	10.17.3.1	Proporciona acceso desde el servidor físico a las máquinas virtuales en esta red.
kube_network_03	10.17.4.1	Gateway para los nodos maestros, workers y almacenamiento.
br0_network	10.17.5.1	Gateway para el nodo Bastion.
Servicios Principales Configurados
Servicio	IP Asociada	Puerto	Uso/Comentarios
WireGuard VPN	192.168.100.2	UDP 51820	Proporciona acceso seguro al servidor físico y las redes internas desde el VPS y equipos externos.
SSH	192.168.0.1 (LAN)	TCP 22	Conexión segura desde la LAN para la gestión del servidor físico y las VMs.
SSH	192.168.100.2 (WAN)	TCP 22	Acceso remoto al servidor físico desde el VPS o equipos externos a través del túnel VPN.
Traefik	10.17.3.12, 10.17.3.13	TCP 80, 443	Balanceo de carga e Ingress Controller para Kubernetes. Maneja tráfico HTTPS desde Cloudflare CDN hacia las aplicaciones desplegadas en el clúster.
DNS (FreeIPA)	10.17.3.11	TCP/UDP 53	Servidor DNS para resolver nombres dentro del clúster.
NFS	10.17.4.27	TCP/UDP 2049	Almacenamiento compartido para el clúster Kubernetes.
Prometheus	10.17.4.21 (Master1)	TCP 9090	Monitoreo del clúster Kubernetes y sus aplicaciones.
Grafana	10.17.4.21 (Master1)	TCP 3000	Visualización de métricas del clúster y servicios desplegados.
Rutas Estáticas en el Servidor Físico
Destino	Gateway	Interfaz	Comentarios
10.17.3.0/24	10.17.3.1	enp4s0f0	Rutas estáticas para la comunicación con los servicios en kube_network_02.
10.17.4.0/24	10.17.4.1	enp4s0f0	Rutas estáticas para los nodos Kubernetes y el almacenamiento en kube_network_03.
192.168.1.0/24	192.168.1.1	enp4s0f1	Rutas específicas para el tráfico dedicado de almacenamiento entre el servidor físico y las VMs (NFS/Longhorn).
10.89.0.0/24	10.89.0.1	enp3s0f0	Ruta hacia la red VPN interna gestionada por WireGuard. Permite acceso seguro desde equipos externos a las redes internas.
Configuración de Firewall con nftables
Regla	Acción	Comentarios
Tráfico SSH LAN (192.168.0.0/24)	Aceptar	Permitir acceso SSH desde la LAN a través de enp4s0f0.
Tráfico SSH desde VPN (10.89.0.0/24)	Aceptar	Permitir acceso SSH desde equipos externos conectados a la VPN.
Tráfico NFS (192.168.1.0/24)	Aceptar	Permitir tráfico dedicado para almacenamiento en la red de almacenamiento.
Tráfico VPN (WireGuard, UDP 51820)	Aceptar	Permitir tráfico VPN hacia el servidor físico desde el VPS o equipos externos.
Tráfico HTTPS (Traefik, TCP 80/443)	Aceptar	Permitir tráfico HTTPS hacia los balanceadores de carga (Traefik).
Bloqueo de tráfico no permitido	Denegar	Rechazar todo tráfico que no esté explícitamente permitido (política por defecto).
Esta tabla resume cómo quedan organizadas las interfaces, redes y servicios, asegurando conectividad interna y externa, redundancia, y seguridad del entorno.