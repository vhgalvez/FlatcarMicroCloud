### Instalación del Proyecto: Flujo Técnico de Instalación Paso a Paso

#### 1. Preparativos Iniciales
- **Clonar Repositorio**: Clona el repositorio en el servidor Rocky Linux.
  ```bash
  git clone https://github.com/vhgalvez/FlatcarMicroCloud.git
  cd FlatcarMicroCloud
  ```

#### 2. Configuración de Redes Virtuales con Terraform
- **Red br0_network**: Navega a `br0_network`.
  ```bash
  cd br0_network
  sudo terraform init --upgrade
  sudo terraform apply
  ```
- **Red nat_network_02**: Navega a `nat_network_02`.
  ```bash
  cd ../nat_network_02
  sudo terraform init --upgrade
  sudo terraform apply
  ```
- **Red nat_network_03**: Navega a `nat_network_03`.
  ```bash
  cd ../nat_network_03
  sudo terraform init --upgrade
  sudo terraform apply
  ```

#### 3. Instalación de VMs y Sistemas Operativos
- **Provisionar y Configurar VMs**: Sigue las especificaciones en la tabla de recursos, asegurando la asignación adecuada de CPU, RAM y almacenamiento.

#### 4. Configuración de Roles en las VMs
- **Master y Worker Nodes**: Configura K3s en los nodos Master y despliega Traefik para balanceo de carga.
- **FreeIPA Node**: Configura para DNS y autenticación.
- **Load Balancer**: Configura con Traefik para distribución de tráfico.
- **PostgreSQL Node**: Configura permisos y define políticas de respaldo.
- **Bootstrap Node**: Ejecuta las configuraciones iniciales del clúster.

#### 5. Configuración de Almacenamiento Persistente
- **Rook y Ceph**: Instala y configura Rook y Ceph en el clúster de Kubernetes para almacenamiento persistente.

#### 6. Configuración de Monitoreo y Visualización
- **Prometheus y Grafana**: Configura para monitoreo de métricas.
- **ELK Stack**: Configura para análisis de logs y visualización de datos.

#### 7. Configuración de CI/CD y Automatización
- **Jenkins, GitHub Actions, y SonarQube**: Configura para integración continua.
- **Harbor, Docker Registry, y Kaniko**: Configura para gestión de imágenes de contenedores.
- **ArgoCD y Spinnaker**: Configura para despliegue continuo.

#### 8. Configuración de Seguridad
- **Firewall, Fail2Ban y FreeIPA**: Configura reglas de seguridad y políticas con FreeIPA.

#### 9. Sincronización y NTP
- **Chronyc**: Configura `chronyc` en todos los nodos para sincronización temporal con FreeIPA.

#### 10. Pruebas Finales y Puesta en Producción
- **Verificación**: Verifica configuración de red y DNS.
- **Pruebas de Despliegue**: Prueba el despliegue de aplicaciones y la monitorización de métricas.
- **Balanceador de Carga**: Asegura que el balanceador de carga y los servicios en Kubernetes estén operativos.

Este flujo garantiza que todas las dependencias y configuraciones sean instaladas en el orden correcto y optimizadas para un entorno de producción.

### Referencias

curl -sfL https://get.k3s.io | K3S_URL=https://K105285ff598aec61abdf70c75ece64e56782d395222d6d8eabc9c49cadd74dcb8f::server:04fd44c81582d038e72d28d2ef7114b7:6443 K3S_TOKEN=<NODE_TOKEN> sh -


sudo curl -sfL https://get.k3s.io | K3S_URL=https://10.17.4.21:6443 K3S_TOKEN=K105285ff598aec61abdf70c75ece64e56782d395222d6d8eabc9c49cadd74dcb8f::server:04fd44c81582d038e72d28d2ef7114b7 sh -

curl -sfL https://get.k3s.io | sh -s - server --node-ip "10.17.4.21" --tls-san "10.17.4.21"


### Acceso a Grafana

http://master1.cefaslocalserver.com:3000

Usuario: admin
Contraseña: prom-operator




