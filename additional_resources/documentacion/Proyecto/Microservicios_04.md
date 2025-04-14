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
Explicación de los parámetros:
image: Utiliza la imagen oficial de Node Exporter de Prometheus (prom/node-exporter:latest).

containerPort: Expondrá las métricas de Node Exporter en el puerto 9100.

volumeMounts y hostPath: Monta directorios del sistema del nodo, como /proc, /sys, /, y /mnt, lo cual es necesario para obtener métricas sobre el sistema de archivos, red y otros parámetros de hardware del nodo.

1.2 Aplicar el DaemonSet
Una vez que tengas el archivo node-exporter-daemonset.yaml, aplícalo a tu clúster Kubernetes con el siguiente comando:

bash
Copiar
Editar
kubectl apply -f node-exporter-daemonset.yaml
Este comando desplegará Node Exporter en todos los nodos de tu clúster de Kubernetes, garantizando que las métricas sean expuestas.

Paso 2: Verificar el estado de los pods de Node Exporter
Después de aplicar el DaemonSet, puedes verifi