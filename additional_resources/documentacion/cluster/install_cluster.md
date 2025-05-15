### Instalación del Proyecto: Flujo Técnico de Instalación Paso a Paso

#### 1. Preparativos Iniciales

1. **Clonar Repositorio**: Clona el repositorio en el servidor Rocky Linux.

    ```bash
    git clone https://github.com/vhgalvez/FlatcarMicroCloud.git
    cd FlatcarMicroCloud
    ```

#### 2. Configuración de Redes Virtuales con Terraform

1. **Red br0_network**: Navega a `br0_network` y aplica la configuración.

    ```bash
    cd br0_network
    sudo terraform init --upgrade
    sudo terraform apply
    ```

2. **Red nat_network_02**: Navega a `nat_network_02` y aplica la configuración.

    ```bash
    cd ../nat_network_02
    sudo terraform init --upgrade
    sudo terraform apply
    ```

3. **Red nat_network_03**: Navega a `nat_network_03` y aplica la configuración.

    ```bash
    cd ../nat_network_03
    sudo terraform init --upgrade
    sudo terraform apply
    ```

#### 3. Instalación de VMs y Sistemas Operativos

1. **Provisionar y Configurar VMs**: Sigue las especificaciones en la tabla de recursos, asegurando la asignación adecuada de CPU, RAM y almacenamiento.

#### 4. Configuración de Roles en las VMs

1. **Master y Worker Nodes**: Configura K3s en los nodos Master y despliega Traefik para balanceo de carga.

2. **FreeIPA Node**: Configura para DNS y autenticación.

3. **Load Balancer**: Configura con Traefik para distribución de tráfico.

4. **PostgreSQL Node**: Configura permisos y define políticas de respaldo.

5. **Bootstrap Node**: Ejecuta las configuraciones iniciales del clúster.

#### 5. Configuración de Almacenamiento Persistente

1. **Rook y Ceph**: Instala y configura Rook y Ceph en el clúster de Kubernetes para almacenamiento persistente.

#### 6. Configuración de Monitoreo y Visualización

1. **Prometheus y Grafana**: Configura para monitoreo de métricas.

2. **ELK Stack**: Configura para análisis de logs y visualización de datos.

#### 7. Configuración de CI/CD y Automatización

1. **Jenkins, GitHub Actions, y SonarQube**: Configura para integración continua.

2. **Harbor, Docker Registry, y Kaniko**: Configura para gestión de imágenes de contenedores.

3. **ArgoCD y Spinnaker**: Configura para despliegue continuo.

#### 8. Configuración de Seguridad

1. **Firewall, Fail2Ban y FreeIPA**: Configura reglas de seguridad y políticas con FreeIPA.

#### 9. Sincronización y NTP

1. **Chronyc**: Configura `chronyc` en todos los nodos para sincronización temporal con FreeIPA.

#### 10. Pruebas Finales y Puesta en Producción

1. **Verificación**: Verifica configuración de red y DNS.

2. **Pruebas de Despliegue**: Prueba el despliegue de aplicaciones y la monitorización de métricas.

3. **Balanceador de Carga**: Asegura que el balanceador de carga y los servicios en Kubernetes estén operativos.

---

### Paso a Paso: Instalar kubectl y Configurar el Nodo Bastion

#### 1. Descarga e Instalación de kubectl

1. **Descargar el binario de kubectl**: Descarga la versión compatible con tu clúster K3s (en este caso, v1.31.2).

    ```bash
    curl -LO "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl"
    ```

2. **Verificar el archivo descargado (opcional)**: Descarga el archivo de verificación sha256 y comprueba la integridad del binario.

    ```bash
    curl -LO "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    ```

    Si el archivo es válido, deberías ver:

    ```plaintext
    kubectl: OK
    ```

3. **Hacer el binario ejecutable**:

    ```bash
    chmod +x kubectl
    ```

4. **Mover el binario a una ubicación del sistema**:

    ```bash
    sudo mv kubectl /usr/local/bin/
    ```

5. **Verificar la instalación de kubectl**:

    ```bash
    kubectl version --client
    ```

    Debe mostrar la versión del cliente de kubectl. Por ejemplo:

    ```plaintext
    Client Version: v1.31.2
    ```

#### 2. Configuración del Acceso al Clúster

1. **Copia el archivo kubeconfig desde un nodo maestro**: Desde el nodo master1, master2, o master3, copia el archivo kubeconfig al nodo Bastion.

    ```bash
    scp root@master1:/etc/rancher/k3s/k3s.yaml ~/.kube/config
    ```

2. **Ajusta los permisos del archivo**: Asegúrate de que el archivo tenga los permisos correctos para evitar problemas de acceso.

    ```bash
    chmod 600 ~/.kube/config
    ```

3. **Editar el archivo kubeconfig**: Abre el archivo `~/.kube/config` con un editor de texto y actualiza el campo `server` para apuntar a la IP del balanceador de carga o a la IP de uno de los nodos maestros accesibles desde Bastion. Por ejemplo:

    ```yaml
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: <data>
        server: https://192.168.0.21:6443 # Cambiar IP aquí
      name: default
    ```

4. **Establece la variable de entorno KUBECONFIG**: Exporta la variable KUBECONFIG para que kubectl utilice el archivo correcto.

    ```bash
    export KUBECONFIG=~/.kube/config
    ```

    Para hacerlo persistente, agrega la línea a tu archivo `~/.bashrc`:

    ```bash
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
    source ~/.bashrc
    ```

5. **Prueba la conectividad al clúster**: Usa el siguiente comando para verificar que kubectl puede comunicarse con tu clúster K3s.

    ```bash
    kubectl get nodes
    ```

    Deberías ver una lista de todos los nodos en tu clúster con su estado:

    ```plaintext
    NAME                           STATUS   ROLES                       AGE    VERSION
    master1.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
    master2.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
    master3.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
    worker1.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
    worker2.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
    worker3.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
    ```

#### Notas Importantes

- Asegúrate de que el nodo Bastion tiene conectividad de red hacia el balanceador de carga o los nodos maestros.

- Verifica que el puerto 6443 (puerto de la API de Kubernetes) esté accesible desde el nodo Bastion.

- Si encuentras problemas, verifica los logs en el nodo maestro (`/var/log/k3s-server.log`) o la conectividad con `ping` y `telnet`.

¡Con esto tendrás kubectl configurado en tu nodo Bastion y listo para gestionar tu clúster! 🚀
