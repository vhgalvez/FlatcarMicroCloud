# Guía de Configuración DNS para Infraestructuras con FreeIPA y CoreDNS

**Nombre del Documento:** Configuración Integrada de FreeIPA y CoreDNS en un Entorno Kubernetes con Balanceador de Carga

**Resumen**

Este documento describe cómo configurar un entorno DNS integrado con FreeIPA y CoreDNS para resolver nombres internos y externos en una infraestructura basada en Kubernetes con un balanceador de carga (`load_balancer1.cefaslocalserver.com`) y un servidor FreeIPA (`freeipa1.cefaslocalserver.com`). La configuración asegura compatibilidad y evita conflictos entre ambos sistemas DNS.

## 1. Configuración de `load_balancer1``load_balancer2` para Resolución DNS con FreeIPA y CoreDNS

El balanceador de carga `load_balancer1``load_balancer2` es un componente crítico que distribuye el tráfico hacia el clúster Kubernetes. Es necesario que pueda resolver tanto nombres de infraestructura como nombres internos del clúster.

### Pasos de Configuración

Configurar FreeIPA como DNS primario y CoreDNS como secundario:

1. Edita el archivo `/etc/resolv.conf` en el balanceador de carga:
   ```plaintext
   nameserver 10.17.3.11  # IP de FreeIPA
   nameserver <CoreDNS_IP>  # IP del servicio CoreDNS en Kubernetes
   ```

**Propósito de cada servidor DNS:**
- **FreeIPA**: Maneja nombres de infraestructura, como `master1.cefaslocalserver.com` o `worker1.cefaslocalserver.com`.
- **CoreDNS**: Resuelve nombres internos del clúster, como `kubernetes.default.svc.cluster.local`.

**Resultado esperado:**

`load_balancer1` intentará resolver nombres en FreeIPA. Si no tiene éxito, las solicitudes se dirigirán a CoreDNS para manejar los dominios internos de Kubernetes.

## 2. Configuración de CoreDNS en los Nodos del Clúster para Integración con FreeIPA

Los nodos del clúster Kubernetes necesitan resolver:

- Nombres internos del clúster, administrados por CoreDNS.
- Nombres de infraestructura externa, administrados por FreeIPA.

### Pasos de Configuración

1. **Modificar el Corefile de CoreDNS**:

   Edita la configuración de CoreDNS para reenviar consultas no resueltas a FreeIPA:
   ```plaintext
   .:53 {
       errors
       health
       ready
       kubernetes cluster.local in-addr.arpa ip6.arpa {
           fallthrough
       }
       forward . 10.17.3.11  # Dirección IP de FreeIPA
       cache 30
       loop
       reload
       loadbalance
   }
   ```

   **Descripción**:
   - `kubernetes cluster.local in-addr.arpa ip6.arpa`: Maneja nombres internos del clúster (por ejemplo, `kubernetes.default.svc.cluster.local`).
   - `forward . 10.17.3.11`: Reenvía consultas no resueltas a FreeIPA para manejar nombres de infraestructura.

2. **Aplicar la configuración**:

   Actualiza el mapa de configuración de CoreDNS en Kubernetes:
   ```bash
   kubectl edit configmap coredns -n kube-system
   ```
   Inserta el bloque de configuración y guarda los cambios.

**Resultado esperado:**

CoreDNS manejará primero las consultas internas de Kubernetes y reenviará cualquier consulta no resuelta a FreeIPA.

## 3. Configuración del Servidor FreeIPA para Resolución DNS Externa

FreeIPA actuará como el servidor DNS principal para toda la infraestructura, con la capacidad de reenviar consultas externas a un servidor DNS público, como Google DNS.

### Pasos de Configuración

1. **Agregar un reenviador de DNS externo en FreeIPA**:

   Ejecuta el siguiente comando en el servidor FreeIPA:
   ```bash
   ipa dnsconfig-mod --forwarder=8.8.8.8
   ```
   Esto configura FreeIPA para reenviar consultas no resueltas a un servidor DNS externo.

2. **Verificar la configuración de FreeIPA**:

   Usa herramientas como `dig` o `nslookup` desde una máquina configurada con FreeIPA como DNS para verificar que puede resolver:
   - Nombres de infraestructura interna, como `master1.cefaslocalserver.com`.
   - Nombres externos, como `www.google.com`.

**Resultado esperado:**

FreeIPA será capaz de resolver nombres internos de infraestructura y consultas externas mediante el reenviador configurado.

## Resumen de Conexiones y Configuración DNS

| Elemento           | DNS Principal         | DNS Secundario        | Rol                                      |
|--------------------|-----------------------|-----------------------|------------------------------------------|
| load_balancer1     | FreeIPA (10.17.3.11)  | CoreDNS (<CoreDNS_IP>) | Resolver nombres internos y externos.    |
| Nodos del Clúster  | CoreDNS (<CoreDNS_IP>) | FreeIPA (10.17.3.11)  | Resolver nombres internos de Kubernetes y externos de FreeIPA. |
| CoreDNS            | Interno               | FreeIPA (10.17.3.11)  | Resolver nombres del clúster y delegar externos a FreeIPA. |
| FreeIPA            | Interno               | Google DNS (8.8.8.8)  | Resolver nombres internos y externos.    |

## Diagrama de Conexiones de Infraestructura DNS

```plaintext
                 +---------------------------+
                 |        IP Pública         |
                 |         (HTTPS)           |
                 |       192.168.0.21        |
                 +---------------------------+
                             |
                             v
                 +---------------------------+
                 |       Bastion Node        |
                 |        SSH Access         |
                 |      IP: 192.168.0.20     |
                 +---------------------------+
                             |
                             v
                 +---------------------------+
                 |      Load Balancer        |
                 |         Traefik           |
                 |      IP: 10.17.3.12       |
                 +---------------------------+
                             |
        +--------------------+--------------------+
        |                                         |
        v                                         v
+---------------------------+      +---------------------------+
|     FreeIPA Node          |      |  PostgreSQL Node          |
|      DNS/Auth             |      |  IP: 10.17.3.13           |
|  IP: 10.17.3.11           |      +---------------------------+
+---------------------------+
                             |
                             v
                 +---------------------------+
                 |  Storage Node (Rook-Ceph) |
                 |      IP: 10.17.3.14       |
                 +---------------------------+
                             |
+----------------+-----------+---------------+-----------------+
|                |                           |                 |
v                v                           v                 v
+------+-------+   +----+-------+   +----+-------+   +----+-------+
| Master Node  |   |   Worker    |   |   Worker    |   |   Worker    |
|     (etcd)   |   |     1       |   |     2       |   |     3       |
| 10.17.4.21   |   | 10.17.4.24  |   | 10.17.4.25  |   | 10.17.4.26  |
+--------------+   +-------------+   +-------------+   +-------------+
       |                                        |
       v                                        v
+--------------+                     +----------------+
| Master Node 2|                     | Master Node 3  |
|   (etcd)     |                     |   (etcd)       |
| 10.17.4.22   |                     | 10.17.4.23     |
+--------------+                     +----------------+
```

## Conclusión

Con esta configuración:

- `load_balancer1` podrá manejar resoluciones de nombres internas y externas gracias a FreeIPA y CoreDNS.
- Los nodos del clúster podrán acceder a nombres internos y externos sin conflictos de resolución.
- FreeIPA se encargará de toda la infraestructura DNS externa e interna con capacidad de delegar consultas no resueltas.

Esto asegura una infraestructura DNS robusta, escalable y sin conflictos.

## Anexo: Tabla de Configuración de Nodos
| Nombre de VM  | CPU | Memoria (MB) | IP         | Nombre de Dominio                      | Tamaño de Disco (GB) | Hostname      |
| ------------- | --- | ------------ | ---------- | -------------------------------------- | -------------------- | ------------- |
| master1       | 2   | 4096         | 10.17.4.21 | master1.cefaslocalserver.com           | 50                   | master1       |
| master2       | 2   | 4096         | 10.17.4.22 | master2.cefaslocalserver.com           | 50                   | master2       |
| master3       | 2   | 4096         | 10.17.4.23 | master3.cefaslocalserver.com           | 50                   | master3       |
| worker1       | 2   | 4096         | 10.17.4.24 | worker1.cefaslocalserver.com           | 50                   | worker1       |
| worker2       | 2   | 4096         | 10.17.4.25 | worker2.cefaslocalserver.com           | 50                   | worker2       |
| worker3       | 2   | 4096         | 10.17.4.26 | worker3.cefaslocalserver.com           | 50                   | worker3       |
| bootstrap     | 2   | 4096         | 10.17.4.27 | bootstrap.cefaslocalserver.com         | 50                   | bootstrap     |
| freeipa1      | 2   | 2048         | 10.17.3.11 | freeipa1.cefaslocalserver.com          | 32                   | freeipa1      |
| loadbalancer1 | 2   | 2048         | 10.17.3.12 | loadbalancer1.cefaslocalserver.com     | 32                   | loadbalancer1 |
| postgresql1   | 2   | 2048         | 10.17.3.13 | postgresql1.cefaslocalserver.com       | 32                   | postgresql1   |
| helper        | 2   | 2048         | 10.17.3.14 | storage1-rook-ceph.cefaslocalserver.com| 80                   | helper_node   |