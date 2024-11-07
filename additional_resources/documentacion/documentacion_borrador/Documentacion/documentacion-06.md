# Configuración del Clúster OpenShift con Servidor ProLiant DL380 G7

## Hardware del Servidor
- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz, adecuada para multitarea intensiva y aplicaciones paralelas.
- **GPU**: AMD ATI 01:03.0 ES1000, para gestión gráfica básica.
- **Memoria**: 1093MiB / 35904MiB, proporcionando amplio espacio para operaciones del clúster.
- **Almacenamiento**:
  - **Disco Duro Principal**: 1.5TB
  - **Disco Duro Secundario**: 3.0TB

## Sistemas Operativos y Virtualización
- **Rocky Linux 9.3 (Blue Onyx)**: Utilizado por su estabilidad y seguridad en entornos de servidor.
- **KVM con Libvirt**: Plataforma de virtualización para la creación y gestión eficiente de VMs.
- **Flatcar Container Linux**: Especializado para la ejecución de contenedores en Kubernetes, facilitando la orquestación.

## Configuración de Red
- **Open vSwitch**: Administra redes virtuales y VLANs, permitiendo un control preciso del tráfico de red.
- **VPN con WireGuard**: Proporciona una conexión remota segura y cifrada.
- **IP Pública**: Facilita el acceso remoto al clúster, gestionada a través del router y el nodo Bastion.
- **DHCP en KVM**: Automatiza la asignación de IPs en las VLANs.
- **Firewall**: Configurado para proteger las VLANs y regular el acceso a servicios del clúster.
- **Modo NAT y Bridge**: Optimiza el tráfico de red, aislando y protegiendo los recursos del clúster.

## Máquinas Virtuales y Contenedores
- **Roles y Configuraciones**:
  - **Bootstrap Node**: Inicia el clúster.
    - **VLAN**: 101, **IP**: 10.17.3.10
  - **Master Nodes** (x3): Coordinan el clúster.
    - **VLAN**: 102, **IPs**: 10.17.3.11, 10.17.3.12, 10.17.3.13
  - **Worker Nodes** (x3): Ejecutan aplicaciones.
    - **VLAN**: 103, **IPs**: 10.17.3.14, 10.17.3.15, 10.17.3.16
  - **Bastion Node**: Punto de acceso seguro y controlado.
    - **VLAN**: 104, **IP**: 10.17.3.21
  - **NFS**: Almacenamiento compartido y persistente.
    - **VLAN**: 105, **IP**: 10.17.3.19
  - **PostgreSQL**: Gestión de bases de datos del clúster.
    - **VLAN**: 105, **IP**: 10.17.3.20
  - **Load Balancer**: Distribuye la carga entre nodos.
    - **VLAN**: 106, **IP**: 10.17.3.18
  - **FreeIPA**: Gestión de identidades y seguridad.
    - **VLAN**: 107, **IP**: 10.17.3.17

## Análisis y Visualización de Datos
- **Elasticsearch y Kibana**: Proporcionan análisis y visualización en tiempo real de logs del clúster.
  - **IP/Dominio**: 10.17.3.22, 10.17.3.23

## Automatización y Orquestación
- **Terraform**: Codifica la infraestructura como código para automatización y replicabilidad.
- **Ansible**: Automatiza configuraciones y tareas operativas post-despliegue.
- **Prometheus y Grafana**: Monitoreo y visualización de métricas del clúster.

## Interfaces de Red Identificadas
- **enp3s0f0**: 192.168.0.24
- **enp3s0f1**: 192.168.0.25
- **enp4s0f0**: 192.168.0.20
- **enp4s0f1**: 192.168.0.26
- **lo (Loopback)**: 127.0.0.1

## Especificaciones de Almacenamiento y Memoria
- **Configuración de Disco y Particiones**:
  - **/dev/sda**: 3.27 TiB
  - **/dev/sdb**: 465.71 GiB
- **Particiones**:
  - **/dev/sda1**: Sistema
  - **/dev/sda2**: 2 GB Linux Filesystem
  - **/dev/sda3**: ~2.89 TiB Linux Filesystem
- **Uso de Memoria**:
  - **Total Memory**: 35GiB
  - **Free Memory**: 33GiB
  - **Swap**: 17GiB
- **Uso del Filesystem**:
  - **/dev/mapper/rl-root**: 100G (7.5G usado)
  - **/dev/sda2**: 1014M (718M usado)
  - **/dev/mapper/rl-home**: 3.0T (25G usado)
