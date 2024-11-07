


# Documentación Técnica del Proyecto

## Respuesta a Preguntas de Configuración de Red y Almacenamiento

### Almacenamiento Persistente: Rook y Ceph
#### ¿Rook y Ceph se instalan en el servidor host local?
Rook y Ceph se instalan dentro del clúster de Kubernetes como pods. No se instalan directamente en el servidor host local, sino que se despliegan en los nodos del clúster para proporcionar almacenamiento distribuido y persistente. Puedes consultar la documentación oficial de Rook y Ceph para más detalles sobre el despliegue en Kubernetes.

### Open vSwitch
#### ¿Es necesario Open vSwitch para la gestión de redes virtuales?
Open vSwitch es altamente recomendado para la gestión avanzada de redes virtuales, incluyendo la configuración de VLANs, enrutamiento de tráfico entre múltiples redes virtuales, y soporte para políticas de seguridad avanzadas. Si necesitas estas características, Open vSwitch es una excelente opción. Sin embargo, si tus requerimientos de red son básicos, podrías utilizar las capacidades de red integradas en KVM y Libvirt.

### Acceso entre Redes NAT
#### ¿Cómo puedo configurar que las redes NAT tengan acceso entre sí?
Para permitir la comunicación entre diferentes redes NAT, puedes utilizar uno de los siguientes métodos:

1. **Configuración de Enrutamiento**: Configura rutas estáticas en el servidor host para redirigir el tráfico entre las diferentes subredes NAT.
2. **Puente de Red**: Usa una red de puente (bridge network) que conecte todas las redes NAT.
3. **NAT en el Bastion Host**: Configura el servidor Bastion para actuar como un router o gateway entre las redes NAT.

Ejemplo de configuración de ruta estática:

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
```


Acceso del Servidor Bastion a las Redes NAT
¿Cómo puede el servidor Bastion con un puente tener acceso a las redes NAT?

El servidor Bastion puede ser configurado para actuar como un gateway entre las redes NAT. Asegúrate de que el servidor Bastion tenga interfaces de red conectadas a cada una de las redes NAT o que tenga rutas configuradas para redirigir el tráfico.

Configuración de IPTables: Usa IPTables para permitir el reenvío de paquetes entre las interfaces de red.
Enrutamiento y Puentes: Configura el servidor Bastion con puentes y rutas adecuadas para asegurar que el tráfico se redirija correctamente.
Ejemplo de configuración de IPTables:

bash
Copiar código
sudo iptables -A FORWARD -i br0 -o virbr0 -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
Salida HTTPS y Acceso Seguro por VPN
¿Tiene salida HTTPS y salida segura por VPN para gestionar el servidor y el clúster?

Sí, puedes configurar salida HTTPS y acceso seguro por VPN de la siguiente manera:

WireGuard VPN: Configura WireGuard en el servidor Bastion para proporcionar acceso seguro a la red interna desde ubicaciones externas. Esto asegurará que todo el tráfico de administración pase por una conexión cifrada.
Configuración de Firewall: Asegúrate de configurar reglas de firewall para permitir tráfico HTTPS y bloquear tráfico no autorizado.
Ejemplo de configuración básica de WireGuard:

ini
Copiar código
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <server-private-key>

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
Certificados SSL/TLS: Utiliza certificados SSL/TLS para asegurar la comunicación HTTPS en los servicios expuestos (por ejemplo, Traefik para balanceo de carga).
Hardware del Servidor
Modelo: ProLiant DL380 G7
CPU: Intel Xeon X5650 (24 cores) @ 2.666GHz
GPU: AMD ATI 01:03.0 ES1000
Memoria: 1093MiB / 35904MiB
Almacenamiento:
Disco Duro Principal: 1.5TB
Disco Duro Secundario: 3.0TB
Sistemas Operativos y Virtualización
Rocky Linux 9.3 (Blue Onyx)
Rocky Linux Minimal
KVM con Libvirt: kvm/qemu y libvirt y Virt-Manager
Flatcar Container Linux
Configuración de Red
Open vSwitch: Gestión de redes virtuales y VLANs
VPN con WireGuard
IP Pública
DHCP en KVM
Firewall
Modo NAT y Bridge
Switch y Router: Facilitan la comunicación y conectividad del clúster.
Máquinas Virtuales y Sistemas Operativos
Bastion Node: Rocky Linux Minimal
Bootstrap Node: Rocky Linux Minimal
Master Nodes: Flatcar Container Linux
Worker Nodes: Flatcar Container Linux
FreeIPA Node: Rocky Linux Minimal
Load Balancer Node: Rocky Linux Minimal
PostgreSQL Node: Rocky Linux Minimal
Máquinas Virtuales y Roles
Bastion Node: Punto de acceso seguro, modo de red Bridge, interfaz enp3s0f1
Bootstrap Node: Inicializa el clúster
Master Nodes: Gestión del clúster
Worker Nodes: Ejecución de aplicaciones
FreeIPA Node: DNS y Gestión de identidades
Load Balancer Node: Traefik para balanceo de carga
PostgreSQL Node: Gestión de bases de datos
Interfaces de Red Identificadas
enp3s0f0: 192.168.0.15
enp3s0f1: 192.168.0.16
enp4s0f0: 192.168.0.20
enp4s0f1: 192.168.0.18
lo (Loopback): 127.0.0.1
Estas interfaces se utilizan para la comunicación y conectividad de la red, incluyendo la configuración de redes virtuales y la gestión de tráfico. Las interfaces están conectadas a un switch y un router de fibra óptica de la compañía de telecomunicaciones, operando bajo DHCP.

Configuración de la Infraestructura de Red
Las direcciones IP pueden cambiar debido a la asignación dinámica de DHCP.
Se utilizará una infraestructura de red para configurar el modo Bridge en el nodo Bastion.
Automatización y Orquestación
Terraform: Automatización de infraestructura
Ansible: Configuración y manejo de operaciones
Microservicios en Pods
Análisis y Visualización de Datos
ELK Stack Elasticsearch: Visualización de métricas del clúster
ELK Stack Kibana: Visualización de datos
ELK Stack Logstash: Procesamiento de logs
Prometheus: Herramientas para el monitoreo, alertas alertmanager y visualización de métricas
Grafana: Visualización de métricas del clúster
cAdvisor: Monitorear el rendimiento y uso de recursos por parte de los contenedores.
Nagios: Rendimiento del sistema
Microservicios de Servicios de Aplicaciones
Nginx: Servidor web y proxy inverso para aplicaciones web.
Apache Kafka: Plataforma de mensajería utilizada para la comunicación entre microservicios.
Redis: Almacenamiento en caché y base de datos en memoria para mejorar el rendimiento de las aplicaciones.
Seguridad y Protección
Firewall: Configuración de reglas de firewall para proteger el clúster.
Fail2Ban: Protección contra accesos no autorizados y ataques.
DNS y FreeIPA: Gestión centralizada de autenticación y políticas de seguridad y Servidor de DNS.
Almacenamiento Persistente
Rook y Ceph: Orquestar Ceph en Kubernetes para almacenamiento persistente.
Especificaciones de Almacenamiento y Memoria
Configuración de Disco y Particiones:
/dev/sda: 3.27 TiB
/dev/sdb: 465.71 GiB
Particiones:
/dev/sda1: Sistema
/dev/sda2: 2 GB Linux Filesystem
/dev/sda3: ~2.89 TiB Linux Filesystem
Uso de Memoria:
Total Memory: 35GiB
Free Memory: 33GiB
Swap: 17GiB
Uso del Filesystem:
/dev/mapper/rl-root: 100G (7.5G usado)
/dev/sda2: 1014M (718M usado)
/dev/mapper/rl-home: 3.0T (25G usado)































Respuesta a Preguntas de Configuración de Red y Almacenamiento
Almacenamiento Persistente: Rook y Ceph
¿Rook y Ceph se instalan en el servidor host local?
Rook y Ceph se instalan dentro del clúster de Kubernetes como pods. No se instalan directamente en el servidor host local, sino que se despliegan en los nodos del clúster para proporcionar almacenamiento distribuido y persistente. Puedes consultar la documentación oficial de Rook y Ceph para más detalles sobre el despliegue en Kubernetes.
Open vSwitch
¿Es necesario Open vSwitch para la gestión de redes virtuales?
Open vSwitch es altamente recomendado para la gestión avanzada de redes virtuales, incluyendo la configuración de VLANs, enrutamiento de tráfico entre múltiples redes virtuales, y soporte para políticas de seguridad avanzadas. Si necesitas estas características, Open vSwitch es una excelente opción. Sin embargo, si tus requerimientos de red son básicos, podrías utilizar las capacidades de red integradas en KVM y Libvirt.
Acceso entre Redes NAT
¿Cómo puedo configurar que las redes NAT tengan acceso entre sí?
Para permitir la comunicación entre diferentes redes NAT, puedes utilizar uno de los siguientes métodos:

Configuración de Enrutamiento: Configura rutas estáticas en el servidor host para redirigir el tráfico entre las diferentes subredes NAT.
Puente de Red: Usa una red de puente (bridge network) que conecte todas las redes NAT.
NAT en el Bastion Host: Configura el servidor Bastion para actuar como un router o gateway entre las redes NAT.
Ejemplo de configuración de ruta estática:

bash
Copiar código
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
Acceso del Servidor Bastion a las Redes NAT
¿Cómo puede el servidor Bastion con un puente tener acceso a las redes NAT?
El servidor Bastion puede ser configurado para actuar como un gateway entre las redes NAT. Asegúrate de que el servidor Bastion tenga interfaces de red conectadas a cada una de las redes NAT o que tenga rutas configuradas para redirigir el tráfico.

Configuración de IPTables: Usa IPTables para permitir el reenvío de paquetes entre las interfaces de red.
Enrutamiento y Puentes: Configura el servidor Bastion con puentes y rutas adecuadas para asegurar que el tráfico se redirija correctamente.
Ejemplo de configuración de IPTables:

bash
Copiar código
sudo iptables -A FORWARD -i br0 -o virbr0 -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
Salida HTTPS y Acceso Seguro por VPN
¿Tiene salida HTTPS y salida segura por VPN para gestionar el servidor y el clúster?
Sí, puedes configurar salida HTTPS y acceso seguro por VPN de la siguiente manera:

WireGuard VPN: Configura WireGuard en el servidor Bastion para proporcionar acceso seguro a la red interna desde ubicaciones externas. Esto asegurará que todo el tráfico de administración pase por una conexión cifrada.
Configuración de Firewall: Asegúrate de configurar reglas de firewall para permitir tráfico HTTPS y bloquear tráfico no autorizado.
Ejemplo de configuración básica de WireGuard:

ini
Copiar código
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <server-private-key>

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
Certificados SSL/TLS: Utiliza certificados SSL/TLS para asegurar la comunicación HTTPS en los servicios expuestos (por ejemplo, Traefik para balanceo de carga).




ip route show


nmcli device reapply enp4s0f0
nmcli device reapply enp3s0f1
nmcli device reapply enp3s0f0
nmcli device reapply enp4s0f1


sudo ip route del default via 192.168.0.1 dev enp3s0f1
sudo ip route del default via 192.168.0.1 dev enp3s0f0
sudo ip route del default via 192.168.0.1 dev enp4s0f1



https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/#google_vignette