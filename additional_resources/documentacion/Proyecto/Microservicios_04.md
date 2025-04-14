# Configuración de Node Exporter en Kubernetes

**Node Exporter** es una herramienta de monitoreo utilizada para recolectar métricas sobre los nodos del clúster, tales como el uso de CPU, memoria, disco, red y otros parámetros de hardware. En este documento, te explicamos cómo configurarlo en un clúster **Kubernetes**, integrándolo con **Prometheus** para la recolección de métricas y **Grafana** para su visualización.

## Paso 1: Crear un DaemonSet de Node Exporter

El **Node Exporter** se implementa generalmente como un **DaemonSet** en Kubernetes. Esto garantiza que se ejecute una copia de **Node Exporter** en cada nodo del clúster, permitiendo que cada nodo exponga métricas que pueden ser recolectadas por **Prometheus**.

### 1.1 Crear el archivo de configuración para el DaemonSet de Node Exporter

Crea un archivo YAML para el **DaemonSet** de **Node Exporter** que se encargará de ejecutar el contenedor en cada nodo del clúster.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /host/root
          readOnly: true
        - name: mount
          mountPath: /host/mount
          readOnly: true
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys
        - name: root
          hostPath:
            path: /
        - name: mount
          hostPath:
            path: /mnt
```

Explicación de los parámetros:

- **image**: Utiliza la imagen oficial de Node Exporter de Prometheus (`prom/node-exporter:latest`).
- **containerPort**: Expondrá las métricas de Node Exporter en el puerto `9100`.
- **volumeMounts** y **hostPath**: Monta directorios del sistema del nodo, como `/proc`, `/sys`, `/`, y `/mnt`, lo cual es necesario para obtener métricas sobre el sistema de archivos, red y otros parámetros de hardware del nodo.

### 1.2 Aplicar el DaemonSet

Una vez que tengas el archivo `node-exporter-daemonset.yaml`, aplícalo a tu clúster Kubernetes con el siguiente comando:

```bash
kubectl apply -f node-exporter-daemonset.yaml
```

Este comando desplegará Node Exporter en todos los nodos de tu clúster de Kubernetes, garantizando que las métricas sean expuestas.

## Paso 2: Verificar el estado de los pods de Node Exporter

Después de aplicar el DaemonSet, puedes verificar que los pods de Node Exporter están funcionando en todos los nodos con el siguiente comando:

```bash
kubectl get pods -n monitoring -l app=node-exporter
```

Este comando mostrará los pods de Node Exporter en el namespace `monitoring`. Si todo está bien configurado, deberías ver un pod corriendo en cada nodo.

## Paso 3: Exponer las métricas de Node Exporter a Prometheus

Para que Prometheus recoja las métricas de Node Exporter, necesitas configurarlo para hacer scraping de los endpoints de métricas expuestos por Node Exporter.

### 3.1 Configuración de Prometheus (`scrape_configs`)

En el archivo de configuración de Prometheus (`prometheus.yml`), agrega una nueva entrada en la sección `scrape_configs` para apuntar a los endpoints de Node Exporter. A continuación, se muestra un ejemplo de configuración:

```yaml
scrape_configs:
  - job_name: 'node-exporter'
    kubernetes_sd_configs:
      - role: node
    metrics_path: /metrics
    relabel_configs:
      - source_labels: [__meta_kubernetes_node_name]
        target_label: instance
```

Explicación:

- **job_name**: Le da un nombre al trabajo de scraping (`node-exporter`).
- **kubernetes_sd_configs**: Utiliza el descubrimiento de servicios de Kubernetes para identificar los nodos del clúster.
- **metrics_path**: Especifica que las métricas están disponibles en `/metrics`, que es la ruta predeterminada de Node Exporter.
- **relabel_configs**: Se utiliza para etiquetar las métricas con el nombre del nodo donde se ejecuta Node Exporter.

### 3.2 Recargar Prometheus

Después de modificar la configuración de Prometheus, necesitas recargar la configuración sin reiniciar el pod. Si estás utilizando Prometheus en Kubernetes, puedes hacer esto ejecutando el siguiente comando:

```bash
kubectl exec -n monitoring <prometheus-pod-name> -- kill -HUP 1
```

Este comando envía una señal `HUP` al proceso de Prometheus, lo que le indica que recargue su configuración.

## Paso 4: Verificación en Grafana

Una vez que Prometheus haya comenzado a recolectar las métricas de Node Exporter, puedes configurar un dashboard en Grafana para visualizar estas métricas.

### Configurar Grafana:

1. Asegúrate de que Grafana esté configurado para usar Prometheus como fuente de datos.
2. Crea un nuevo dashboard o utiliza uno preexistente que lea las métricas de Node Exporter desde Prometheus.
3. **Añadir paneles**: Utiliza los paneles de Grafana para visualizar las métricas de uso de CPU, memoria, disco, red, etc.

## Resumen de los pasos

1. **Crear el DaemonSet de Node Exporter**:
   - Desplegar un DaemonSet en Kubernetes para que Node Exporter se ejecute en todos los nodos.
2. **Aplicar el DaemonSet**:
   - Usar `kubectl apply` para desplegar Node Exporter.
3. **Configurar Prometheus**:
   - Modificar el archivo `prometheus.yml` para que Prometheus haga scraping de las métricas de Node Exporter.
4. **Recargar Prometheus**:
   - Asegurarse de que Prometheus recargue la configuración.
5. **Configurar Grafana**:
   - Visualizar las métricas recolectadas por Prometheus en Grafana.

## Comandos útiles

- **Aplicar DaemonSet de Node Exporter**:

  ```bash
  kubectl apply -f node-exporter-daemonset.yaml
  ```

- **Verificar los pods de Node Exporter**:

  ```bash
  kubectl get pods -n monitoring -l app=node-exporter
  ```

- **Recargar la configuración de Prometheus**:

  ```bash
  kubectl exec -n monitoring <prometheus-pod-name> -- kill -HUP 1
  ```

- **Comprobar las métricas de Node Exporter en Prometheus**:

  ```bash
  kubectl port-forward -n monitoring svc/prometheus-server 9090:9090
  ```

Con estos pasos, habrás desplegado Node Exporter en tu clúster Kubernetes, y Prometheus podrá recolectar las métricas expuestas, mientras que Grafana las visualizará para un monitoreo completo de tus nodos.