# Infraestructura del Clúster OpenShift con Servidor ProLiant DL380 G7

## 1. Servidor y Hardware
- **ProLiant DL380 G7**: Servidor robusto y escalable, ideal para cargas de trabajo intensivas.
- **Intel Xeon X5650**: Procesador de 24 núcleos a 2.666GHz, ideal para multitarea y aplicaciones paralelas.
- **AMD ATI ES1000**: GPU para gestión gráfica básica.
- **Memoria y Almacenamiento**:
  - **RAM**: 1093MiB / 35904MiB.
  - **Disco Duro**: 1.5TB / 3.0TB.

## 2. Sistemas Operativos y Virtualización
### Sistemas Operativos
- **Rocky Linux 9.3 (Blue Onyx)**: Utilizado para operaciones que requieren estabilidad y seguridad en un entorno de servidor.
- **Rocky Linux 9.3 Minimal**: Utilizado en el nodo Bastion para ejecutar aplicaciones nativas con mínimas instalaciones adicionales, asegurando seguridad y eficiencia.
- **Flatcar Container Linux**: Especializado para ejecutar contenedores Kubernetes, proporcionando un sistema optimizado y ligero.

### Virtualización
- **KVM con Libvirt**: Plataforma de virtualización utilizada para crear y gestionar las máquinas virtuales del clúster.

## 3. Redes y Conectividad
- **Open vSwitch**: Utilizado para la configuración avanzada de redes virtuales y VLANs.
- **VPN con WireGuard**: Configurado para conexiones seguras y remotas.
- **Switch y Router**: Hardware que facilita la conexión y comunicación dentro y fuera del clúster.
- **IP Pública**: Proporcionada por el proveedor de servicios de Internet para acceso remoto global.

## 4. Automatización y Orquestación
- **Terraform**: Automatiza la creación de infraestructura como código.
- **Ansible**: Gestiona configuraciones y automatiza operaciones post-despliegue.
- **Prometheus y Grafana**: Monitorean y visualizan métricas del clúster para mantenimiento proactivo y diagnóstico.

## 5. Seguridad y Protección
- **Firewall y Fail2Ban**: Protegen el clúster de accesos no autorizados y ataques.
- **DNS y FreeIPA**: Proporcionan gestión de políticas de seguridad y servicios de nombres.

## 6. Configuración de Red
- **Modo NAT y Bridge**: Configuraciones optimizadas para controlar el tráfico interno y permitir accesos controlados desde y hacia el clúster.
- **DHCP en KVM**: Gestiona la asignación automática de direcciones IP dentro del clúster.

## 7. Máquinas Virtuales y Contenedores
- **Roles de Máquinas**:
  - **Bootstrap Node**: 1 CPU, 1024 MB - Inicia el clúster.
  - **Master Nodes**: 2 CPUs, 2048 MB cada uno - Gestionan el clúster.
  - **Worker Nodes**: 2 CPUs, 2048 MB cada uno - Ejecutan aplicaciones.
  - **Bastion Node**: 1 CPU, 1024 MB - Ofrece acceso seguro en modo bridge.

## 8. Servicios de Almacenamiento y Bases de Datos
- **NFS**: Almacenamiento compartido para datos persistentes.
- **PostgreSQL**: Gestiona bases de datos cruciales para la operatividad del clúster.

## 9. Análisis y Visualización de Datos
- **Elasticsearch y Kibana**: Facilitan el análisis y la visualización de logs del clúster en tiempo real.

## 10. Servicios de Aplicaciones
- **Nginx**: Sirve como servidor web y proxy inverso.
- **Apache Kafka**: Utilizado para la comunicación entre microservicios dentro del clúster.

## 11. Interfaces de Red Identificadas
- **enp3s0f0**: 192.168.0.24
- **enp3s0f1**: 192.168.0.25
- **enp4s0f0**: 192.168.0.20
- **enp4s0f1**: 192.168.0.26
- **lo (Loopback)**: 127.0.0.1
