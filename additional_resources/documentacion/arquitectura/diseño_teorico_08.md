Configuraciones Detalladas y Validaciones
1. Configuración de Interfaces en pfSense
Accede a Interfaces > Assignments en la GUI de pfSense y realiza las siguientes configuraciones:

WAN:

Interfaz física: vtnet0 (asociada a br0).
Dirección IP: 192.168.0.200.
Máscara de subred: /24.
Puerta de enlace: 192.168.0.1.
DNS:
Servidores públicos como Cloudflare (1.1.1.1, 1.0.0.1) o Google (8.8.8.8).
LAN:

Interfaz física: vtnet1 (asociada a br1).
Dirección IP: 192.168.1.1.
Máscara de subred: /24.
DHCP:
Rango: 192.168.1.100-192.168.1.200.
DMZ (Opcional):

Interfaz física: vtnet2.
Dirección IP: 192.168.2.1.
Máscara de subred: /24.
DHCP:
Rango: 192.168.2.100-192.168.2.150.
2. Configuración de Reglas de Firewall
Accede a Firewall > Rules y configura las siguientes reglas:

WAN (Acceso Externo):

Regla 1: Permitir tráfico para VPN (WireGuard):
Protocolo: UDP.
Puerto destino: 51820.
Origen: Any.
Destino: WAN Address.
Descripción: "Allow WireGuard VPN".
Regla 2: Bloquear todo tráfico no permitido:
Protocolo: Any.
Acción: Deny.
Descripción: "Block all other traffic".
LAN (Acceso Interno):

Regla 1: Permitir tráfico saliente hacia cualquier destino:
Protocolo: Any.
Origen: LAN net.
Destino: Any.
Descripción: "Allow LAN to Any".
Regla 2: Permitir acceso a la GUI de pfSense y SSH:
Protocolo: TCP.
Puertos destino: 80, 443, 22.
Origen: LAN net.
Destino: LAN Address.
Descripción: "Allow LAN to pfSense".
DMZ (Opcional):

Regla 1: Permitir tráfico saliente hacia Internet:
Protocolo: TCP.
Origen: 192.168.2.0/24.
Destino: Any.
Descripción: "Allow DMZ to Internet".
Regla 2: Bloquear tráfico desde DMZ hacia la LAN:
Protocolo: Any.
Origen: 192.168.2.0/24.
Destino: 192.168.1.0/24.
Acción: Deny.
Descripción: "Block DMZ to LAN".
3. Configuración de NAT
Accede a Firewall > NAT > Outbound y selecciona:

Modo Automático:
Permite a pfSense manejar automáticamente la traducción de direcciones para las redes internas.
Modo Manual (Opcional):
Configura reglas específicas para NAT en las subredes LAN, DMZ y VPN hacia la WAN.
4. Configuración de DNS
Accede a Services > DNS Resolver y configura:

LAN y DMZ:

Habilita el DNS Resolver para que los dispositivos internos resuelvan nombres.
Agrega entradas DNS locales para servicios en el cluster Kubernetes o servidores públicos.
VPN:

Agrega la dirección de pfSense (192.168.1.1) como servidor DNS en la configuración del servidor VPN.
5. Configuración de WireGuard VPN (Opcional)
Accede a VPN > WireGuard y realiza estas configuraciones:

Configuración del servidor:

Dirección IP: 10.17.0.1.
Rango de clientes: 10.17.0.0/24.
Puerto: 51820.
Reglas de Firewall:

Permite tráfico UDP en el puerto 51820 en la interfaz WAN.
Clientes:

Configura dispositivos remotos con claves públicas y privadas.
6. Configuración del Cluster de Kubernetes
Exposición del Ingress Controller:

Usa la red LAN (192.168.1.0/24) para exponer servicios del controlador de Ingress.
Reglas de Firewall:

Permitir tráfico hacia puertos HTTP/HTTPS (80, 443) desde la LAN al Ingress Controller.
Pruebas:

Desde la LAN, accede a servicios desplegados en el cluster usando los dominios configurados en el Ingress.
7. Verificación Final
Acceso Interno:

Desde la LAN, accede a la GUI de pfSense (192.168.1.1).
Verifica que dispositivos conectados a la LAN tienen acceso a Internet.
Pruebas de Firewall:

Ve a Diagnostics > States para revisar las conexiones activas.
Validación de NAT:

Asegúrate de que las subredes LAN, DMZ y VPN tienen acceso a Internet.
VPN:

Conéctate desde un cliente remoto y verifica:
Acceso a subredes LAN y DMZ.
Acceso a Internet.
8. Futuro: Exposición Pública con VPS
Configuración del VPS:

Asigna una IP pública al VPS y configura un proxy inverso hacia pfSense.
Configura NAT en el VPS para redirigir tráfico HTTP/HTTPS hacia los servicios en el Ingress.
Seguridad:

Usa Cloudflare para proteger el dominio y realizar cacheo.
