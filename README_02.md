### Integración continua CI/CD

- **Jenkins**: Automatización de pruebas y despliegue de aplicaciones.
- **GitHub Actions**: Control de versiones y CI/CD.
- **SonarQube**: Análisis de código y calidad.
- **Docker Registry**: Registro de imágenes de contenedores.
- **Harbor**: Registro de imágenes de contenedores y escaneo de vulnerabilidades.
- **Kaniko**: Construcción de imágenes de contenedores sin privilegios.
- **Helm**: Gestión de paquetes de Kubernetes.
- **Kustomize**: Personalización de despliegues de Kubernetes.
- **ArgoCD**: Despliegue continuo de aplicaciones en Kubernetes.
- **Tekton**: Automatización de pipelines de CI/CD.
- **Spinnaker**: Automatización de despliegues en Kubernetes.


- **Kubernetes Operators**: Automatización de operaciones en Kubernetes.
- **Kubernetes Helm Charts**: Plantillas predefinidas para despliegues en Kubernetes.
- **Kubernetes Custom Resources**: Recursos personalizados para operaciones específicas en Kubernetes.
- **Kubernetes Ingress**: Gestión de tráfico de red en Kubernetes.
- **Kubernetes Services**: Exposición de servicios en Kubernetes.
- **Kubernetes Volumes**: Almacenamiento persistente en Kubernetes.
- **Kubernetes Namespaces**: Aislamiento de recursos en Kubernetes.
- **Kubernetes RBAC**: Control de acceso basado en roles en Kubernetes.
- **Kubernetes Secrets**: Gestión de secretos en Kubernetes.
- **Kubernetes ConfigMaps**: Gestión de configuraciones en Kubernetes.
- **Kubernetes Network Policies**: Políticas de red en Kubernetes.
- **Kubernetes Pod Security Policies**: Políticas de seguridad en Kubernetes.
- **Kubernetes Pod Disruption Budgets**: Control de la disponibilidad de pods en Kubernetes.
- **Kubernetes Horizontal Pod Autoscaler**: Escalado automático de pods en Kubernetes.
- **Kubernetes Vertical Pod Autoscaler**: Escalado automático de recursos en pods en Kubernetes.
- **Kubernetes Cluster Autoscaler**: Escalado automático de nodos en Kubernetes.
- **Kubernetes Pod Affinity**: Afinidad de pods en Kubernetes.
- **Kubernetes Pod Anti-Affinity**: Anti-afinidad de pods en Kubernetes.
- **Kubernetes Taints and Tolerations**: Tolerancias y restricciones en Kubernetes.
- **Kubernetes DaemonSets**: Despliegue de pods en todos los nodos en Kubernetes.
- **Kubernetes StatefulSets**: Despliegue de aplicaciones con estado en Kubernetes.
- **Kubernetes Jobs**: Ejecución de tareas en Kubernetes.


# Resumen del Flujo

1. Las **conexiones HTTPS** externas ingresan por la **IP pública (192.168.0.21)**.
2. El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al
5. **FreeIPA** actúa como **servidor DNS y NTP**, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con FreeIPA a través de **chronyc**.

# Resumen del Flujo

1. **Ingreso de Conexiones Externas**: Las conexiones HTTPS externas ingresan por la **IP pública (192.168.0.21)**.
2. **Acceso Seguro**: El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. **Distribución de Tráfico**: El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. **Instalación de OKD**: El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al **FreeIPA**.
5. **Resolución de Nombres y Sincronización de Tiempo**:
   - **FreeIPA** actúa como servidor DNS y NTP, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. **Ejecución de Aplicaciones**: Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con **FreeIPA** a través de **chronyc**.



# Resumen del Flujo

1. Las **conexiones HTTPS** externas ingresan por la **IP pública (192.168.0.21)**.
2. El tráfico pasa por el **Bastion Node (192.168.0.20)** para acceder de manera segura a la red interna.
3. El **Load Balancer (Traefik)** distribuye el tráfico hacia los nodos maestros y workers.
4. El **Bootstrap Node** inicia la instalación de OKD, solicitando los certificados al
5. **FreeIPA** actúa como **servidor DNS y NTP**, asegurando la resolución de nombres y la sincronización temporal en todo el clúster.
6. Los **nodos workers** ejecutan las aplicaciones, manteniendo la sincronización temporal con FreeIPA a través de **chronyc**.
