# Configuración del Clúster OpenShift con Servidor ProLiant DL380 G7

## Hardware del Servidor
- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria**: 1093MiB / 35904MiB
- **Almacenamiento**:
  - **Disco Duro Principal**: 1.5TB
  - **Disco Duro Secundario**: 3.0TB

## Sistemas Operativos y Virtualización
- **Rocky Linux 9.3 (Blue Onyx)**: Utilizado por su estabilidad y seguridad en entornos de servidor.
- **KVM con Libvirt**: Plataforma de virtualización para la creación y gestión eficiente de VMs.
- **Flatcar Container Linux**: Especializado para la ejecución de contenedores en Kubernetes.

## Configuración de Red
- **Open vSwitch**: Administra redes virtuales y VLANs, permitiendo un control preciso del tráfico de red.
- **VPN con WireGuard**: Proporciona una conexión remota segura y cifrada.
- **IP Pública**: Facilita el acceso remoto al clúster, gestionada a través del router y el nodo Bastion.
- **DHCP en KVM**: Automatiza la asignación de IPs en las VLANs.
- **Firewall**: Configurado para proteger las VLANs y regular el acceso a servicios del clúster.
- **Modo NAT y Bridge**: Optimiza el tráfico de red, aislando y protegiendo los recursos del clúster.

## Máquinas Virtuales y Contenedores
- **Roles y Configuraciones**:
  - **Bastion Node**: Punto de acceso seguro y controlado.
    - **CPU**: 1 core
    - **Memoria**: 1024 MB
    - **IP/Dominio**: 10.17.3.21/bastion.cefaslocalserver.com
    - **VLAN**: 104
    - **Modo de Red**: Bridge con interfaz física
    - **Interfaz de Red**: Conexión bridge a `enp3s0f1` para facilitar la gestión segura de accesos SSH y la administración del clúster a través de una conexión protegida.

### Detalles de Configuración de Bridge para el Bastion Node
Para configurar el **Bastion Node** en modo bridge, se establece un enlace directo con la interfaz física `enp3s0f1`. Esto permite que el Bastion Node actúe como un puente entre la red interna del clúster y la red externa, facilitando un acceso seguro y controlado:

1. **Interfaz Física Asignada**: `enp3s0f1`
2. **Configuración de Bridge**:
   - La IP pública es asignada a esta interfaz, permitiendo conexiones entrantes desde Internet de manera segura.
   - El tráfico desde y hacia el Bastion se filtra y regula a través del firewall configurado para permitir solo conexiones seguras y autorizadas.

## Automatización y Orquestación
- **Terraform y Ansible**: Herramientas clave para la automatización de infraestructura y configuraciones.

## Análisis y Visualización de Datos
- **Elasticsearch y Kibana**: Claves para el análisis y visualización en tiempo real de los logs y eventos del clúster.

## Interfaces de Red Identificadas
- **enp3s0f0**: 192.168.0.24
- **enp3s0f1**: 192.168.0.25 (Utilizada para Bridge en Bastion Node)
- **enp4s0f0**: 192.168.0.20
- **enp4s0f1**: 192.168.0.26
- **lo (Loopback)**: 127.0.0.1

## Especificaciones de Almacenamiento y Memoria
- **Particiones y Uso del Disco**: Detalladas para optimizar el rendimiento y la seguridad de los datos.

Esta configuración garantiza que el Bastion Node sirva como un punto de control seguro para el acceso administrativo al clúster, aprovechando las capacidades de red avanzadas y las configuraciones de seguridad robustas.

# Configuración Detallada del Acceso y Conectividad en el Clúster OpenShift

## Entrada de la IP Pública y Conexión SSH

### IP Pública
- La **IP pública** es asignada al router que proporciona la conectividad a Internet para el clúster. Esta IP pública es crucial para acceder al clúster desde ubicaciones remotas fuera de la red local del clúster.
- La configuración del firewall en el router debe asegurarse de dirigir adecuadamente el tráfico entrante destinado al **Bastion Node** para la gestión segura del clúster.

### Configuración de la VPN
- **WireGuard** se utiliza como la solución VPN para proporcionar un canal seguro de comunicación.
- La VPN está configurada para escuchar en la **IP pública** del router, permitiendo conexiones cifradas desde el exterior.
- El tráfico que llega a través de la VPN es redirigido hacia el **Bastion Node**, que actúa como el punto de entrada al clúster para la administración remota segura.

### Bastion Node y SSH
- El **Bastion Node** está configurado en modo bridge con la interfaz física `enp3s0f1`, que se conecta directamente al router.
- A través de esta configuración de bridge, el Bastion Node recibe tráfico SSH dirigido desde la VPN.
- Solo los usuarios autenticados con credenciales válidas pueden acceder al clúster a través de SSH, lo cual es gestionado y asegurado por **FreeIPA** en el nodo Bastion.
- Todas las conexiones SSH hacia otros nodos del clúster (como nodos Master y Worker) se originan desde el Bastion, asegurando que todo el acceso interno al clúster sea regulado y seguro.

### Firewall y Seguridad
- El firewall en el Bastion Node está configurado para permitir solo conexiones SSH entrantes desde la dirección IP del túnel VPN.
- Se implementan reglas adicionales en el firewall para bloquear intentos no autorizados y proteger contra ataques comunes.

## Diagrama de Flujo de Red

Internet -> IP Pública en Router -> VPN (WireGuard) -> Firewall -> Bastion Node (enp3s0f1, modo bridge) -> SSH hacia otros nodos


## Integración de Nginx como Servidor Web y Balanceador de Carga

### Configuración del Servidor Nginx
- Se instala y configura Nginx en un servidor independiente dentro del clúster o fuera de él, según la preferencia de arquitectura.
- Nginx se configura para actuar como un proxy inverso y balanceador de carga.
- En la configuración de Nginx, se definen los servidores upstream para apuntar a los nodos del clúster OpenShift, proporcionando así la conectividad al clúster.
- Se establecen reglas de enrutamiento en Nginx para dirigir el tráfico entrante hacia los nodos del clúster, distribuyendo la carga de manera equitativa entre ellos.

### Integración con el Clúster OpenShift
- Se configuran los servicios en el clúster OpenShift que deben ser accesibles a través del servidor Nginx, como aplicaciones web o APIs.
- Se ajustan las configuraciones de red y seguridad en el clúster para permitir la comunicación entrante desde el servidor Nginx.
- Se establece una conexión segura entre el servidor Nginx y los nodos del clúster, utilizando métodos de autenticación adecuados, como certificados SSL/TLS o tokens de acceso.
- 
## Diagrama de Flujo de Red

Internet -> IP Pública en Router -> VPN (WireGuard) -> Firewall -> Bastion Node (enp3s0f1, modo bridge) -> SSH hacia otros nodos
                                                    |
                                                    v
                                            Servidor Nginx (Proxy inverso y balanceador de carga) -> Clúster OpenShift


# Configuración de Redes Virtuales y VLANs en el Clúster OpenShift
### VLAN 101

#### Máquinas Virtuales (KVM)

| Máquina    | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|------------|-------------|--------------|-------------|----------------------------------|
| Bootstrap1 | 1           | 1024         | 10.17.3.10  | bootstrap.cefaslocalserver.com  |

### VLAN 102

#### Máquinas Virtuales (KVM)

| Máquina   | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|-----------|-------------|--------------|-------------|----------------------------------|
| Master1   | 2           | 2048         | 10.17.3.11  | master1.cefaslocalserver.com     |
| Master2   | 2           | 2048         | 10.17.3.12  | master2.cefaslocalserver.com     |
| Master3   | 2           | 2048         | 10.17.3.13  | master3.cefaslocalserver.com     |

### VLAN 103

#### Máquinas Virtuales (KVM)

| Máquina   | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|-----------|-------------|--------------|-------------|----------------------------------|
| Worker1   | 2           | 2048         | 10.17.3.14  | worker1.cefaslocalserver.com     |
| Worker2   | 2           | 2048         | 10.17.3.15  | worker2.cefaslocalserver.com     |
| Worker3   | 2           | 2048         | 10.17.3.16  | worker3.cefaslocalserver.com     |

### VLAN 104

#### Máquinas Virtuales (KVM)

| Máquina   | CPU (cores) | Memoria (MB) | IP          | Dominio                          | Modo de Red |
|-----------|-------------|--------------|-------------|----------------------------------|-------------|
| Bastion1  | 1           | 1024         | 10.17.3.21  | bastion.cefaslocalserver.com     | Bridge      |

### VLAN 105

#### Máquinas Virtuales (KVM)

| Máquina        | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|----------------|-------------|--------------|-------------|----------------------------------|
| NFS1           | 1           | 1024         | 10.17.3.19  | nfs.cefaslocalserver.com         |
| PostgreSQL1    | 1           | 1024         | 10.17.3.20  | postgresql.cefaslocalserver.com  |

### VLAN 106

#### Máquinas Virtuales (KVM)

| Máquina          | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|------------------|-------------|--------------|-------------|----------------------------------|
| Load Balancer1  | 1           | 1024         | 10.17.3.18  | loadbalancer.cefaslocalserver.com|

### VLAN 107

#### Máquinas Virtuales (KVM)

| Máquina   | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|-----------|-------------|--------------|-------------|----------------------------------|
| FreeIPA1  | 1           | 1024         | 10.17.3.17  | dns.cefaslocalserver.com         |

### Análisis y Visualización de Datos

#### Máquinas Virtuales (KVM)

| Máquina         | CPU (cores) | Memoria (MB) | IP          | Dominio                          |
|-----------------|-------------|--------------|-------------|----------------------------------|
| Elasticsearch1 | 2           | 2048         | 10.17.3.22  | elasticsearch.cefaslocalserver.com|
| Kibana1         | 1           | 1024         | 10.17.3.23  | kibana.cefaslocalserver.com      |
