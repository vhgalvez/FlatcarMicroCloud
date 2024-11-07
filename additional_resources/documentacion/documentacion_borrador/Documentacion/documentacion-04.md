# Infraestructura de Servidor y Clúster OpenShift

## 1. Servidor y Hardware
- **ProLiant DL380 G7**: Servidor de alta capacidad, ideal para tareas intensivas.
- **Intel Xeon X5650**: CPU de 24 núcleos a 2.666GHz, diseñada para multitarea y paralelismo.
- **AMD ATI ES1000**: GPU para tareas de gestión gráfica básica.
- **Memoria y Almacenamiento**:
  - **RAM**: 1093MiB / 35904MiB
  - **Disco Duro**: 1.5TB / 3.0TB

## 2. Sistemas Operativos y Virtualización
- **Rocky Linux 9.3 (Blue Onyx)**: Sistema operativo estable y seguro, adecuado para servidores.
- **KVM con Libvirt**: Tecnología de virtualización para la gestión eficiente de máquinas virtuales.
- **Flatcar Container Linux**: Optimizado para la ejecución de contenedores, especialmente en entornos Kubernetes.
- **DHCP en KVM**: Configuración automática de direcciones IP para las máquinas virtuales dentro del clúster.

## 3. Redes y Conectividad
- **Open vSwitch**: Gestión avanzada de redes virtuales y VLANs.
- **VPN con WireGuard**: Proporciona conexiones remotas seguras.
- **Switch y Router**: Facilitan la comunicación y conectividad del clúster.
- **IP Pública**: Proveída por el proveedor de Internet, permite el acceso remoto al clúster desde el exterior.

## 4. Automatización y Orquestación
- **Terraform**: Herramienta para la automatización de la infraestructura como código.
- **Ansible**: Gestión de configuraciones y automatización de operaciones post-despliegue.
- **Prometheus y Grafana**: Herramientas para el monitoreo y la visualización de métricas del clúster.

## 5. Seguridad y Protección
- **Firewall y Fail2Ban**: Protección contra accesos no autorizados y ataques.
- **DNS y FreeIPA**: Gestión centralizada de autenticación y políticas de seguridad.

## 6. Máquinas Virtuales y Contenedores
- **Roles de Máquinas**:
  - **Bootstrap Node**: Inicia el clúster.
  - **Master Nodes**: Gestión del clúster.
  - **Worker Nodes**: Ejecución de aplicaciones.
  - **Bastion Node**: Acceso seguro, en modo bridge.
  - **Load Balancer**: Distribución de carga con HAProxy/Traefik.

## 7. Servicios de Almacenamiento y Bases de Datos
- **NFS**: Para almacenamiento compartido y persistente.
- **PostgreSQL**: Base de datos para la gestión de datos del clúster.

## 8. Análisis y Visualización de Datos
- **Elasticsearch y Kibana**: Análisis y visualización en tiempo real de los logs y eventos del clúster.

## 9. Servicios de Aplicaciones
- **Nginx**: Servidor web y proxy inverso para aplicaciones web.
- **Apache Kafka**: Plataforma de mensajería utilizada para la comunicación entre microservicios.

## 10. Configuración de Red
- **Modo NAT y Bridge**: Para optimizar el tráfico interno y externo.
- **Interfaces de Red Identificadas**:
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
- 
## 11. Uso Específico de Rocky Linux 9.3 Minimal
- **Rocky Linux 9.3 Minimal**: Esta versión ligera de Rocky Linux es ideal para máquinas virtuales que requieren un sistema operativo eficiente con mínimas herramientas preinstaladas, permitiendo un mejor control y menor sobrecarga en recursos del sistema.
- **Aplicación en Nodo Bastion**:
  - **Propósito**: El nodo Bastion opera como un punto de acceso seguro para la administración del clúster. Al utilizar Rocky Linux 9.3 Minimal, se asegura que el sistema sea seguro y estable, con solo los componentes esenciales instalados, lo que reduce las vulnerabilidades y optimiza el rendimiento.
  - **Configuración**:
    - **CPU**: 1 CPU asignada.
    - **Memoria**: 1024 MB de RAM.
    - **Funciones**: Facilita la gestión segura de accesos SSH y la administración del clúster a través de una conexión protegida.
    - **Modo de Red**: Funciona en modo bridge para proporcionar un puente seguro entre la red interna del clúster y la red externa.
- **Ventajas de Rocky Linux 9.3 Minimal en Ambientes Virtuales**:
  - **Optimización de Recursos**: Menor consumo de recursos de CPU y memoria en comparación con versiones completas.
  - **Seguridad Mejorada**: Al instalar menos paquetes, se minimizan las potenciales brechas de seguridad, haciendo el sistema más fácil de auditar y mantener seguro.
  - **Rapidez en la Implementación**: Al ser una versión minimal, la instalación y configuración es más rápida, lo que es ideal para entornos que necesitan despliegues ágiles de VM.

## Interfaces de Red Identificadas para Nodo Bastion
- **IP Pública**: Configurada para permitir el acceso remoto al Bastion de manera segura desde el exterior utilizando la IP proporcionada por el proveedor de Internet.
- **Detalles de la Configuración**:
  - **enp3s0f0**: 192.168.0.24, configurada para manejar el tráfico entrante y saliente específico del nodo Bastion.
