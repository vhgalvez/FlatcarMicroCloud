# Configuración de Alta Disponibilidad de Kubernetes con NGINX y Balanceo de Carga

Este proyecto configura un entorno Kubernetes de alta disponibilidad con balanceadores de carga y servicios esenciales. También se despliega un microservicio para el servidor web NGINX, accesible en [https://cefaslocalserver.com](https://cefaslocalserver.com). A continuación, se presenta una guía paso a paso para organizar y completar el proyecto.

## Configuración Global de Infraestructura y Paso a Paso

### 1. Configuración de Red
#### 1.1. Configuración de IP Pública
- **Dirección**: `192.168.0.21`
- **Dominio asociado**: `cefaslocalserver.com` para acceso HTTPS.

#### 1.2. Asignar IPs Internas
- **Balanceadores de Carga**:
  - Balanceador de Carga 1: `10.17.3.12`
  - Balanceador de Carga 2: `10.17.3.13`
- **Nodos y Servicios Internos**:
  - FreeIPA: `10.17.3.11`
  - PostgreSQL: `10.17.3.14`
  - Almacenamiento (Rook-Ceph): `10.17.3.15`
  - **Nodos de Kubernetes**:
    - Maestros: `10.17.4.21`, `10.17.4.22`, `10.17.4.23`
    - Trabajadores: `10.17.4.24`, `10.17.4.25`, `10.17.4.26`
  - Nodo Bastion: `192.168.0.20` para acceso SSH

#### 1.3. Configuración de DNS Local en FreeIPA
- Crear registros DNS con Round-Robin para balanceo de carga:
  ```bash
  ipa dnsrecord-add cefaslocalserver.com loadbalancer --a-rec=10.17.3.12
  ipa dnsrecord-add cefaslocalserver.com loadbalancer --a-rec=10.17.3.13
  ipa dnsrecord-add cefaslocalserver.com k8sapi --a-rec=192.168.0.21
  ```
- Verificar la resolución DNS:
  ```bash
  dig cefaslocalserver.com @10.17.3.11
  ```

### 2. Configuración del Balanceador de Carga
#### 2.1. Instalar y Configurar Traefik
- Instalar Traefik en `10.17.3.12` y `10.17.3.13`.
- Configurar rutas en `traefik.toml`:
  - `https://cefaslocalserver.com` → Usuarios públicos.
  - `https://loadbalancer.cefaslocalserver.com` → Administración del clúster.

#### 2.2. Habilitar HTTPS con Let's Encrypt
- Configurar certificados automáticos.

#### 2.3. Prueba del Balanceador de Carga
- Acceso desde el navegador: [https://cefaslocalserver.com](https://cefaslocalserver.com).

### 3. Configuración del Microservicio NGINX
#### 3.1. Crear Deployment de NGINX
- **nginx-deployment.yaml**:
  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: nginx
    namespace: default
  spec:
    replicas: 2
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:alpine
          ports:
          - containerPort: 80
  ```

#### 3.2. Crear Servicio para NGINX
- **nginx-service.yaml**:
  ```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx
    namespace: default
  spec:
    selector:
      app: nginx
    ports:
    - protocol: TCP
      port: 80
      targetPort: 80
    type: ClusterIP
  ```

#### 3.3. Crear Ingress para Exponer NGINX
- **nginx-ingress.yaml**:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: nginx-ingress
    namespace: default
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: websecure
      traefik.ingress.kubernetes.io/router.tls: "true"
  spec:
    rules:
    - host: cefaslocalserver.com
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: nginx
              port:
                number: 80
    tls:
    - hosts:
      - cefaslocalserver.com
      secretName: nginx-tls
  ```

#### 3.4. Aplicar Configuración

```bash
kubectl apply -f nginx-deployment.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f nginx-ingress.yaml
```

### 4. Configuración de FreeIPA y CoreDNS

#### 4.1. Configurar CoreDNS para Reenviar a FreeIPA

- Editar ConfigMap de CoreDNS:
  ```yaml
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: coredns
    namespace: kube-system
  data:
    Corefile: |
      .:53 {
          errors
          health
          ready
          kubernetes cluster.local in-addr.arpa ip6.arpa {
              fallthrough
          }
          forward . 10.17.3.11
          cache 30
          loop
          reload
          loadbalance
      }
  ```

#### 4.2. Verificar Resolución DNS

```bash
kubectl run -it --rm dnsutils --image=infoblox/dnstools
nslookup cefaslocalserver.com
```

### 5. Configuración de Kubernetes

#### 5.1. Actualizar .kube/config
- Cambiar el servidor para apuntar al balanceador de carga:
  ```yaml
  server: https://loadbalancer.cefaslocalserver.com
  ```

#### 5.2. Probar Acceso al API Server
```bash
kubectl get nodes
```

### 6. Configuración de Almacenamiento
#### 6.1. Desplegar Rook-Ceph
- Desplegar en `10.17.3.15`.

#### 6.2. Almacenamiento Persistente para NGINX (Opcional)

- Añadir un Persistent Volume Claim (PVC) si es necesario.

### 7. Configuración del Nodo Bastion

#### 7.1. Configurar Acceso SSH Seguro
- Utilizar WireGuard o túneles SSH para acceso seguro.

### 8. Validaciones Finales

#### 8.1. Probar Aplicación Web
- Acceso desde el navegador: [https://cefaslocalserver.com](https://cefaslocalserver.com).

#### 8.2. Probar Resolución DNS

- Desde nodos y pods:
  ```bash
  nslookup cefaslocalserver.com
  ```

#### 8.3. Verificar Balanceo de Carga

- Detener uno de los balanceadores de carga y confirmar que el otro responde correctamente.

### 9. Acceso a Kubernetes desde los Balanceadores

#### 9.1. Copiar el archivo .kube/config
- En los nodos `loadbalancer1` y `loadbalancer2`, copiar el archivo `.kube/config` desde `master1` y colocarlo en `/etc/traefik/kubeconfig`:
  ```bash
  scp /home/core/.kube/config core@loadbalancer1:/etc/traefik/kubeconfig
  scp /home/core/.kube/config core@loadbalancer2:/etc/traefik/kubeconfig
  ```

#### 9.2. Asegurar Permisos Correctos
- Asegúrate de que el archivo tenga los permisos correctos:
  ```bash
  sudo chmod 600 /etc/traefik/kubeconfig
  ```