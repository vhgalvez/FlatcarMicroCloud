# Configuración de DNS en Rocky Linux y Flatcar Linux

Aquí tienes una guía paso a paso para configurar la resolución de DNS manualmente en tus máquinas virtuales, tanto para Rocky Linux como para Flatcar Linux. Esta guía cubre cómo actualizar el archivo resolv.conf y configurar NetworkManager en cada sistema operativo.

Configuración de DNS en Rocky Linux

Paso 1: Editar `/etc/resolv.conf`

Accede a la máquina Rocky Linux (bastion, freeipa, load_balancer, postgresql) mediante SSH.

Abre el archivo `/etc/resolv.conf` con un editor de texto:


```bash
sudo nano /etc/resolv.conf
```

Añade las entradas de los servidores DNS:


```bash
nameserver 10.17.3.11
nameserver 8.8.8.8
```

Guarda y cierra el archivo.

Paso 2: Hacer que el archivo resolv.conf sea inmutable
Ejecuta el siguiente comando para evitar que el archivo resolv.conf sea modificado por otros servicios:

```bash
sudo chattr +i /etc/resolv.conf
```

Paso 3: Configurar NetworkManager

Crea un archivo de configuración para NetworkManager:

```bash
sudo nano /etc/NetworkManager/conf.d/dns.conf
```

Añade el siguiente contenido:

```bash
[main]
dns=none
```

Guarda y cierra el archivo.

Reinicia NetworkManager para aplicar los cambios:

```bash
sudo systemctl restart NetworkManager
```

Configuración de DNS en Flatcar Linux

Paso 1: Acceder a la máquina Flatcar Linux

Accede a la máquina Flatcar Linux (bootstrap, master1, master2, master3, worker1, worker2, worker3) mediante SSH.

Paso 2: Editar `/etc/resolv.conf`

Monta el sistema de archivos / como read-write:

```bash
sudo mount -o remount,rw /
```

Abre el archivo /etc/resolv.conf con un editor de texto:

```bash
sudo nano /etc/resolv.conf
```

Añade las entradas de los servidores DNS:

```bash
nameserver 10.17.3.11
nameserver 8.8.8.8
```

Guarda y cierra el archivo.

Paso 3: Hacer que el archivo resolv.conf sea inmutable

Ejecuta el siguiente comando para evitar que el archivo resolv.conf sea modificado por otros servicios:


```bash
sudo chattr +i /etc/resolv.conf
```

Paso 4: Configurar systemd-networkd

Crea un archivo de configuración para systemd-networkd:

```bash
sudo nano /etc/systemd/network/00-dns.conf
```

Añade el siguiente contenido:

```bash
[Network]
DNS=10.17.3.11 8.8.8.8
```

Guarda y cierra el archivo.

Reinicia systemd-networkd para aplicar los cambios:


```bash
sudo systemctl restart systemd-networkd
```

Paso 5: Montar el sistema de archivos / como read-only (opcional)
Si deseas volver a montar el sistema de archivos / como read-only:


```bash
sudo mount -o remount,ro /
```

Validación de la Configuración

Después de realizar los cambios en cada máquina, puedes validar la configuración de DNS ejecutando el siguiente comando:


```bash
nslookup <hostname>
```

Por ejemplo:


```bash
nslookup master1.localcefas.com
```

Si la configuración es correcta, deberías ver la dirección IP correspondiente al nombre de host.

Resumen de los Hostnames e IPs

10.17.4.20 bootstrap.serverlocalcefas.com
10.17.4.21 master1.serverlocalcefas.com
10.17.4.22 master2.serverlocalcefas.com
10.17.4.23 master3.serverlocalcefas.com
10.17.4.24 worker1.serverlocalcefas.com
10.17.4.25 worker2.serverlocalcefas.com
10.17.4.26 worker3.serverlocalcefas.com
192.168.0.20 bastion1.serverlocalcefas.com
10.17.3.11 freeipa.serverlocalcefas.com

192.168.0.20 bastion1.serverlocalcefas.com

Esta guía debe ayudarte a configurar manualmente la resolución de DNS en tus máquinas virtuales Rocky Linux y Flatcar Linux.


# Configuración de DNS en Rocky Linux

```bash
10.17.4.20 bootstrap1.cefaslocalserver.com
10.17.4.21 master1.cefaslocalserver.com
10.17.4.22 master2.cefaslocalserver.com
10.17.4.23 master3.cefaslocalserver.com
10.17.4.24 worker1.cefaslocalserver.com
10.17.4.25 worker2.cefaslocalserver.com
10.17.4.26 worker3.cefaslocalserver.com
192.168.0.20 bastion1.cefaslocalserver.com
10.17.3.11 freeipa.cefaslocalserver.com
192.168.0.20 bastion1.cefaslocalserver.com
```

```bash
10.17.4.20 bootstrap1.cefaslocalserver.com
10.17.4.21 master1.cefaslocalserver.com
10.17.4.22 master2.cefaslocalserver.com
10.17.4.23 master3.cefaslocalserver.com
10.17.4.24 worker1.cefaslocalserver.com
10.17.4.25 worker2.cefaslocalserver.com
10.17.4.26 worker3.cefaslocalserver.com
192.168.0.20 bastion.cefaslocalserver.com
10.17.3.11 freeipa.cefaslocalserver.com
192.168.0.20 bastion1.cefaslocalserver.com
```

## Redes Virtuales y Configuración



## Tabla de Configuración de Redes - br0 - Bridge Network

| Red NAT | Nodos    | Dirección IP | Rol del Nodo                               | Interfaz de Red |
| ------- | -------- | ------------ | ------------------------------------------ | --------------- |
| br0     | bastion1 | 192.168.0.20 | Acceso seguro, Punto de conexión de bridge | `enp3s0f1`      |

## Tabla de Configuración de Redes - kube_network_02 - NAT Network

| Red NAT         | Nodos          | Dirección IP | Rol del Nodo                             | Interfaz de Red |
| --------------- | -------------- | ------------ | ---------------------------------------- | --------------- |
| kube_network_02 | freeipa1       | 10.17.3.11   | Servidor de DNS y gestión de identidades | (Virtual - NAT) |
| kube_network_02 | load_balancer1 | 10.17.3.12   | Balanceo de carga para el clúster        | (Virtual - NAT) |
| kube_network_02 | postgresql1    | 10.17.3.13   | Gestión de bases de datos                | (Virtual - NAT) |

## Tabla de Configuración de Redes - kube_network_03 - NAT Network

| Red NAT         | Nodos      | Dirección IP | Rol del Nodo               | Interfaz de Red |
| --------------- | ---------- | ------------ | -------------------------- | --------------- |
| kube_network_03 | bootstrap1 | 10.17.4.20   | Inicialización del clúster | (Virtual - NAT) |
| kube_network_03 | master1    | 10.17.4.21   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | master2    | 10.17.4.22   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | master3    | 10.17.4.23   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | worker1    | 10.17.4.24   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | worker2    | 10.17.4.25   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | worker3    | 10.17.4.26   | Ejecución de aplicaciones  | (Virtual - NAT) |

### Detalles de las Máquinas Virtuales por Red

#### br0 - Bridge Network

| Máquina  | CPU (cores) | Memoria (MB) | IP  | Dominio                      | Sistema Operativo       |
| -------- | ----------- | ------------ | --- | ---------------------------- | ----------------------- |
| Bastion1 | 1           | 2024         |     | bastion1.cefaslocalserver.com | Rocky Linux 9.3 Minimal |

#### kube_network_02 - NAT Network

| Máquina       | CPU (cores) | Memoria (MB) | IP         | Dominio                            | Sistema Operativo |
| ------------- | ----------- | ------------ | ---------- | ---------------------------------- | ----------------- |
| FreeIPA1      | 2           | 2048         | 10.17.3.11 | freeipa1.cefaslocalserver.com      | Rocky Linux 9.3   |
| LoadBalancer1 | 2           | 2048         | 10.17.3.12 | loadbalancer1.cefaslocalserver.com | Rocky Linux 9.3   |
| PostgreSQL1   | 2           | 2048         | 10.17.3.13 | postgresql1.cefaslocalserver.com   | Rocky Linux 9.3   |

#### kube_network_03 - NAT Network

| Máquina    | CPU (cores) | Memoria (MB) | IP         | Dominio                         | Sistema Operativo       |
| ---------- | ----------- | ------------ | ---------- | ------------------------------- | ----------------------- |
| Bootstrap1 | 2           | 2048         | 10.17.4.20 | bootstrap1.cefaslocalserver.com | Flatcar Container Linux |
| Master1    | 2           | 2048         | 10.17.4.21 | master1.cefaslocalserver.com    | Flatcar Container Linux |
| Master2    | 2           | 2048         | 10.17.4.22 | master2.cefaslocalserver.com    | Flatcar Container Linux |
| Master3    | 2           | 2048         | 10.17.4.23 | master3.cefaslocalserver.com    | Flatcar Container Linux |
| Worker1    | 2           | 2048         | 10.17.4.24 | worker1.cefaslocalserver.com    | Flatcar Container Linux |
| Worker2    | 2           | 2048         | 10.17.4.25 | worker2.cefaslocalserver.com    | Flatcar Container Linux |
| Worker3    | 2           | 2048         | 10.17.4.26 | worker3.cefaslocalserver.com    | Flatcar Container Linux |


## Tabla de Configuración de Redes

### Tabla de Configuración de Redes - br0

| Red NAT | Nodos      | Dirección IP | Rol del Nodo                               | Interfaz de Red |
| ------- | ---------- | ------------ | ------------------------------------------ | --------------- |
| br0     | `bastion1` | 192.168.0.20 | Acceso seguro, Punto de conexión de bridge | `enp3s0f1`      |

### Tabla de Configuración de Redes - kube_network_02

| Red NAT         | Nodos            | Dirección IP | Rol del Nodo                             | Interfaz de Red |
| --------------- | ---------------- | ------------ | ---------------------------------------- | --------------- |
| kube_network_02 | `freeipa1`       | 10.17.3.11   | Servidor de DNS y gestión de identidades | (Virtual - NAT) |
| kube_network_02 | `load_balancer1` | 10.17.3.12   | Balanceo de carga para el clúster        | (Virtual - NAT) |
| kube_network_02 | `postgresql1`    | 10.17.3.13   | Gestión de bases de datos                | (Virtual - NAT) |

### Tabla de Configuración de Redes - kube_network_03

| Red NAT         | Nodos        | Dirección IP | Rol del Nodo               | Interfaz de Red |
| --------------- | ------------ | ------------ | -------------------------- | --------------- |
| kube_network_03 | `bootstrap1` | 10.17.4.20   | Inicialización del clúster | (Virtual - NAT) |
| kube_network_03 | `master1`    | 10.17.4.21   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | `master2`    | 10.17.4.22   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | `master3`    | 10.17.4.23   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | `worker1`    | 10.17.4.24   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | `worker2`    | 10.17.4.25   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | `worker3`    | 10.17.4.26   | Ejecución de aplicaciones  | (Virtual - NAT) |


## Tabla de Configuración de Redes - br0 - Bridge Network

| Nombre   | Dirección IP    |
|----------|-----------------|
| enp3s0f1 | 192.168.0.52/24 | 
| enp4s0f0 | 192.168.0.18/24 | 
| enp4s0f1 | 192.168.0.35/24 |
| virbro   | 10.17.3.1/24    |
| virbr1   | 10.17.4.1/24    |



```hcl
# Red br0 - Bridge Network - Rocky Linux 9.3
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}


# Red kube_network_02 - NAT Network
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}

# Red kube_network_03 - NAT Network
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
```
