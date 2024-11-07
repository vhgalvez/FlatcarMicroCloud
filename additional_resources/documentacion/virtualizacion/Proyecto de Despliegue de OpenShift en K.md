# Proyecto de Despliegue de OpenShift en KVM utilizando Terraform

Requisitos

Terraform: v0.13 o superior
Acceso a un servidor KVM con libvirt
Estructura del Proyecto
bastion_network/
nat_network_02/
nat_network_03/
Instrucciones de Ejecución
Inicializar y Aplicar Terraform para bastion_network:

```bash
cd bastion_network
sudo terraform init --upgrade
sudo terraform apply
```
Inicializar y Aplicar Terraform para nat_network_02:

```bash
cd ../nat_network_02
sudo terraform init --upgrade
sudo terraform apply
```
Inicializar y Aplicar Terraform para nat_network_03:

```bash
cd ../nat_network_03
sudo terraform init --upgrade
sudo terraform apply
```
Detalles de las Máquinas Virtuales

bastion_network:

Nombre: bastion1
CPU: 2
Memoria: 2048 MB
IP: 192.168.0.35
Rol: Acceso seguro, Punto de conexión de bridge
Sistema Operativo: Rocky Linux 9.3 Minimal
nat_network_02:

Nombre: freeipa1

CPU: 2
Memoria: 2048 MB
IP: 10.17.3.11
Rol: Servidor de DNS y gestión de identidades
Sistema Operativo: Rocky Linux 9.3
Nombre: load_balancer1

CPU: 2
Memoria: 2048 MB
IP: 10.17.3.12
Rol: Balanceo de carga para el clúster
Sistema Operativo: Rocky Linux 9.3
Nombre: postgresql1

CPU: 2
Memoria: 2048 MB
IP: 10.17.3.13
Rol: Gestión de bases de datos
Sistema Operativo: Rocky Linux 9.3
nat_network_03:

Nombre: bootstrap1

CPU: 1
Memoria: 1024 MB
IP: 10.17.4.20
Rol: Inicialización del clúster
Sistema Operativo: Flatcar Container Linux
Nombre: master1

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.21
Rol: Gestión del clúster
Sistema Operativo: Flatcar Container Linux
Nombre: master2

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.22
Rol: Gestión del clúster
Sistema Operativo: Flatcar Container Linux
Nombre: master3

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.23
Rol: Gestión del clúster
Sistema Operativo: Flatcar Container Linux
Nombre: worker1

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.24
Rol: Ejecución de aplicaciones
Sistema Operativo: Flatcar Container Linux
Nombre: worker2

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.25
Rol: Ejecución de aplicaciones
Sistema Operativo: Flatcar Container Linux
Nombre: worker3

CPU: 2
Memoria: 2048 MB
IP: 10.17.4.26
Rol: Ejecución de aplicaciones
Sistema Operativo: Flatcar Container Linux
Detalles de las Máquinas Virtuales por Red
br0 - Bridge Network:

Máquina	CPU (cores)	Memoria (MB)	IP	Dominio	Sistema Operativo
Bastion1	1	2024		bastion.cefaslocalserver.com	Rocky Linux 9.3 Minimal
kube_network_02 - NAT Network:

Máquina	CPU (cores)	Memoria (MB)	IP	Dominio	Sistema Operativo
FreeIPA1	2	2048	10.17.3.11	freeipa1.cefaslocalserver.com	Rocky Linux 9.3
LoadBalancer1	2	2048	10.17.3.12	loadbalancer1.cefaslocalserver.com	Rocky Linux 9.3
PostgreSQL1	2	2048	10.17.3.13	postgresql1.cefaslocalserver.com	Rocky Linux 9.3
kube_network_03 - NAT Network:

Máquina	CPU (cores)	Memoria (MB)	IP	Dominio	Sistema Operativo
Bootstrap1	2	2048	10.17.4.20	bootstrap1.cefaslocalserver.com	Flatcar Container Linux
Master1	2	2048	10.17.4.21	master1.cefaslocalserver.com	Flatcar Container Linux
Master2	2	2048	10.17.4.22	master2.cefaslocalserver.com	Flatcar Container Linux
Master3	2	2048	10.17.4.23	master3.cefaslocalserver.com	Flatcar Container Linux
Worker1	2	2048	10.17.4.24	worker1.cefaslocalserver.com	Flatcar Container Linux
Worker2	2	2048	10.17.4.25	worker2.cefaslocalserver.com	Flatcar Container Linux
Worker3	2	2048	10.17.4.26	worker3.cefaslocalserver.com	Flatcar Container Linux
Tabla de Configuración de Redes
Tabla de Configuración de Redes - br0:

Red NAT	Nodos	Dirección IP	Rol del Nodo	Interfaz de Red
br0	bastion1	192.168.0.20	Acceso seguro, Punto de conexión de bridge	enp3s0f1
Tabla de Configuración de Redes - kube_network_02:

Red NAT	Nodos	Dirección IP	Rol del Nodo	Interfaz de Red
kube_network_02	freeipa1	10.17.3.11	Servidor de DNS y gestión de identidades	(Virtual - NAT)
kube_network_02	load_balancer1	10.17.3.12	Balanceo de carga para el clúster	(Virtual - NAT)
kube_network_02	postgresql1	10.17.3.13	Gestión de bases de datos	(Virtual - NAT)
Tabla de Configuración de Redes - kube_network_03:

Red NAT	Nodos	Dirección IP	Rol del Nodo	Interfaz de Red
kube_network_03	bootstrap1	10.17.4.20	Inicialización del clúster	(Virtual - NAT)
kube_network_03	master1	10.17.4.21	Gestión del clúster	(Virtual - NAT)
kube_network_03	master2	10.17.4.22	Gestión del clúster	(Virtual - NAT)
kube_network_03	master3	10.17.4.23	Gestión del clúster	(Virtual - NAT)
kube_network_03	worker1	10.17.4.24	Ejecución de aplicaciones	(Virtual - NAT)
kube_network_03	worker2	10.17.4.25	Ejecución de aplicaciones	(Virtual - NAT)
kube_network_03	worker3	10.17.4.26	Ejecución de aplicaciones	(Virtual - NAT)
Tabla de Configuración de Redes - br0 - Bridge Network:

Nombre	Dirección IP
enp3s0f1	192.168.0.52/24
enp4s0f0	192.168.0.18/24
enp4s0f1	192.168.0.35/24
virbro	10.17.3.1/24
virbr1	10.17.4.1/24
Información Detallada de la Máquina
Detalles de la Red:

Dirección IP	Hostname	Alias	Interfaz de Red	Estado de la Interfaz	IP Asignada	Máscara de Subred
192.168.0.21	physical1.cefaslocalserver.com	physical1	enp3s0f1	UP	192.168.0.52/24	255.255.255.0
192.168.0.18			enp4s0f0	UP	192.168.0.18/24	255.255.255.0
192.168.0.35			enp4s0f1	UP	192.168.0.35/24	255.255.255.0
192.168.0.28			br0	UP	192.168.0.28/24 (Primary)	255.255.255.0
192.168.0.21			br0	UP	192.168.0.21/24 (Secondary)	255.255.255.0
10.17.3.1			virbr0	UP	10.17.3.1/24	255.255.255.0
10.17.4.1			virbr1	UP	10.17.4.1/24	255.255.255.0
Detalles Adicionales de la Máquina:

Máquina	CPU (cores)	Memoria (MB)	IP	Dominio	Sistema Operativo
physical1	24	35904	192.168.0.21	physical1.cefaslocalserver.com	Rocky Linux 9.4
Puentes de Red:
Nombre del Puente	Puente ID	STP Habilitado	Interfaces Conectadas
br0	8000.2c768aacdebc	Sí	enp3s0f0, vnet0
virbr0	8000.525400b64c99	Sí	vnet1, vnet2, vnet3
virbr1	8000.52540016b5de	Sí	vnet4, vnet5, vnet6, vnet7, vnet8, vnet9, vnet10
Información del Sistema
plaintext
Copiar código
        #####           victory@physical1.cefaslocalserver.com
       #######          --------------------------------------
       ##O#O##          OS: Rocky Linux 9.4 (Blue Onyx) x86_64
       #######          Host: ProLiant DL380 G7
     ###########        Kernel: 5.14.0-427.22.1.el9_4.x86_64
    #############       Uptime: 3 hours, 5 mins
   ###############      Packages: 1301 (rpm)
   ################     Shell: bash 5.1.8
  #################     Resolution: 1024x768
#####################   Terminal: /dev/pts/16
#####################   CPU: Intel Xeon X5650 (24) @ 2.665GHz
  #################     GPU: AMD ATI 01:03.0 ES1000
   ################
                        Memory: 21362MiB / 35904MiB
Definición de Redes en Terraform
hcl
Copiar código
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

Tecnologías Utilizadas

Terraform

KVM con Libvirt

Rocky Linux 9.3 y 9.4
Flatcar Container Linux
WireGuard (VPN)
Traefik (Balanceador de carga)
ELK Stack (Elasticsearch, Kibana, Logstash)
Prometheus y Grafana
cAdvisor
Nagios
Nginx
Apache Kafka
Redis
Rook y Ceph

Con este detallado listado, puedes tener una vista clara y ordenada de todas las tecnologías, IPs, máquinas virtuales, y configuraciones involucradas en el proyecto de despliegue de OpenShift en KVM utilizando Terraform.




