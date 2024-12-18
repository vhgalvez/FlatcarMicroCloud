# Diseño Teórico para el Caso Propuesto

## 1. Requisitos Identificados

### Usuarios Administrativos (LAN):
- Ubicados físicamente en la misma red que el servidor.
- Acceso a servicios del clúster (KVM, Kubernetes, etc.) con autenticación por clave SSH y contraseña.
- Necesitan acceso seguro a las VMs para gestionar servicios web y aplicaciones internas.

### Usuarios Administrativos (Remotos):
- Teletrabajadores que necesitan gestionar el clúster y las VMs.
- Conexión mediante un túnel VPN a la LAN del servidor.

### Usuarios Externos (Clientes o Públicos):
- Acceso a servicios expuestos por las VMs o aplicaciones en el clúster.
- Todo el tráfico externo debe pasar por un servidor en la nube con IP pública para ocultar la red interna.

### Políticas de Seguridad:
- Acceso segmentado y controlado entre usuarios administrativos y otros usuarios internos.
- Uso de túneles VPN para aislar tráfico administrativo.
- Enrutamiento seguro para el tráfico externo.

---

## 2. Arquitectura Propuesta

```plaintext
+-----------------------------+
|     Usuarios Públicos       |
|  (Acceso HTTP/HTTPS)        |
+-----------------------------+
              |
              v
    +----------------------+             +-----------------------------+
    |    Servidor en la    |  <=======>  |       Usuarios Remotos      |
    |       Nube (VPN)     |             | (Teletrabajo y gestión)     |
    +----------------------+             +-----------------------------+
              |
              v
+----------------------------------+                   +----------------------------+
|  Servidor Físico en la LAN       |                   |   Estaciones de Trabajo    |
|                                  |                   | (Acceso seguro LAN VPN)    |
|  [WireGuard Gateway]             |                   |                            |
|  [KVM, VMs, Kubernetes Cluster]  |                   +----------------------------+
|  [Servicios Web Internos]        |
+----------------------------------+
```


## 3. Configuración Detallada

### 3.1 Configuración para Usuarios Administrativos (LAN)

Acceso a través de VPN LAN:
Implementar una VPN interna con WireGuard dentro de la LAN.
Asignar una red privada para el túnel VPN (ejemplo: 10.17.0.0/24).
Conexión para servicios internos:
Consolas web de VMs.
Aplicaciones web en VMs (Kubernetes o KVM).
Autenticación:
Uso de claves SSH y contraseñas para acceso a servicios administrativos.
Limitación del acceso por direcciones IP internas confiables.
Rutas y Firewalls:
Permitir acceso solo desde la subred de la VPN (10.17.0.0/24) a los puertos administrativos.
Restringir el tráfico entre usuarios normales de la LAN y los servicios internos.

### 3.2 Configuración para Usuarios Administrativos (Remotos)
Acceso mediante VPN Externa:
Configurar un servidor WireGuard VPN en la nube.
Conexión con el servidor físico a través de un túnel encriptado.
Subred para VPN externa: 10.18.0.0/24.
Redirección y Políticas:
Todo el tráfico administrativo remoto pasa por la nube hacia el servidor físico.
Limitar accesos a servicios específicos según el rol del usuario.
Autenticación y Seguridad:
Claves privadas WireGuard y autenticación multifactor (MFA).
Auditorías periódicas para detectar accesos no autorizados.

### 3.3 Configuración para Usuarios Públicos
Servicios Expuestos a Internet:
Exponer solo servicios esenciales (HTTP/HTTPS) mediante un proxy inverso en la nube (ejemplo: Cloudflare).
Uso de certificados SSL para asegurar conexiones.
Proxy configurado para redirigir tráfico al balanceador de carga (Traefik) dentro de la LAN.
Aislamiento del Servidor Físico:
El servidor físico no debe estar directamente expuesto.
Todo el tráfico público pasa por el servidor en la nube.
Firewall:
Bloquear acceso directo desde IPs públicas al servidor físico.

## 4. Políticas de Seguridad
Firewall con nftables:
Reglas para separar tráfico administrativo, interno y público:

```bash
# Permitir tráfico VPN Interna
ip saddr 10.17.0.0/24 accept;

# Permitir tráfico VPN Externa
ip saddr 10.18.0.0/24 accept;

# Permitir acceso público a servicios expuestos
tcp dport {80, 443} accept;

# Bloquear todo el tráfico no autorizado
policy drop;
```


Acceso Restringido:
Usuarios administrativos solo acceden a servicios según su rol.
Usuarios públicos no tienen acceso directo al servidor físico.
Monitoreo y Alertas:
Implementar Prometheus y Grafana para monitorear recursos y conexiones.
Configurar alertas en caso de accesos sospechosos.

## 5. Beneficios de la Configuración

Redundancia: Conexión administrativa interna y remota.
Seguridad: Separación clara entre usuarios administrativos y públicos.
Flexibilidad: Soporte para usuarios internos y externos con acceso controlado.
Escalabilidad: Facilidad para añadir nuevos usuarios o servicios.



+-----------------------------+                               
| Usuarios Públicos           |                               
+-----------------------------+                               
              |                                                   
              v                                                   
+-----------------------------+                               
| Router Físico               |                               
| DHCP: 192.168.0.100-254     |                               
| Gateway: 192.168.0.1        |                               
+-----------------------------+                               
              |                                                   
              v                                                   
+-----------------------------+                                
| br0: 192.168.0.20           |                                
| (WAN del servidor físico)   |                                
+-----------------------------+                                
              |                                                   
              v                                                   
+-----------------------------+                                
| pfSense (VM)                |                                
| WAN: 192.168.0.200          |                                
| LAN: 192.168.1.1            |                                
| DHCP: 192.168.1.100-200     |                                
+-----------------------------+                                
              |                                                   
              v                                                   
+-----------------------------+                                
| br1: LAN Virtual            |                                
| Subred: 192.168.1.0/24      |                                
+-----------------------------+   