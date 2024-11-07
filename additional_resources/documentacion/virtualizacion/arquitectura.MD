                            +---------------------+
                            |    IP Pública       |
                            | (Conexiones HTTPS)  |
                            |     192.168.0.21    |
                            +----------+----------+
                                       |
                                       v
                           +-----------+----------+
                           |  Load Balancer (Traefik)  |
                           |   IP: 10.17.3.12          |
                           +-----------+----------+
                                       |
                  +--------------------+--------------------+
                  |                    |                    |
                  v                    v                    v
          +-------+-------+    +-------+-------+    +-------+-------+
          |   Master 1    |    |   Master 2    |    |   Master 3    |
          |   IP: 10.17.4.21|    |   IP: 10.17.4.22|    |   IP: 10.17.4.23|
          +-------+-------+    +-------+-------+    +-------+-------+
                  |                    |                    |
                  +--------------------+--------------------+
                                       |
                                       v
                           +-----------+----------+
                           |  Bootstrap (OKD)     |
                           |   IP: 10.17.4.20     |
                           +-----------+----------+
                                       |
                                       v
         +--------------------+--------------------+--------------------+
         |                    |                    |                    |
         v                    v                    v                    v
+-------+-------+    +-------+-------+    +-------+-------+    +-------+-------+
|   Worker 1    |    |   Worker 2    |    |   Worker 3    |    |  FreeIPA (DNS)|
|   IP: 10.17.4.24|    |   IP: 10.17.4.25|    |   IP: 10.17.4.26|    |  IP: 10.17.3.11|
+-------+-------+    +-------+-------+    +-------+-------+    +-------+-------+

         +--------------------------------------------------------------------+
         |                            Bastion Node                            |
         |             Acceso Seguro, Punto de Conexión de Bridge            |
         |                       IP: 192.168.0.20                            |
         +--------------------------------------------------------------------+
                                       |
                                       v
                           +-----------+----------+
                           |      Servidor Físico      |
                           |   IP: 192.168.0.21        |
                           +---------------------------+
                                       |
                                       v
                           +---------------------------+
                           |   Switch y Router         |
                           +---------------------------+
                                       |
                                       v
                           +---------------------------+
                           |        Internet           |
                           +---------------------------+




                         +---------------------+
                         |    Internet         |
                         +---------------------+
                                   |
                         +---------------------+
                         |     IP Pública      |
                         |  (Load Balancer)    |
                         +---------------------+
                                   |
                          +--------+--------+
                          |                 |
+---------------------+  HTTPS            VPN/SSH
|    Load Balancer    |  Traffic          Traffic
|     (Traefik)       |                    |
|    IP: 10.17.3.12   |                    |
+---------------------+                    |
          |                                |
          |                                |
+---------------------+   +---------------------+
|   OKD Master Node 1 |   |    Bastion Node     |
|    IP: 10.17.4.21   |   |  VPN, SSH, Firewall |
+---------------------+   |  IP: 192.168.0.20   |
                          +---------------------+
+---------------------+
|   OKD Master Node 2 |
|    IP: 10.17.4.22   |
+---------------------+

+---------------------+
|   OKD Master Node 3 |
|    IP: 10.17.4.23   |
+---------------------+

+---------------------+
|    OKD Worker 1     |
|    IP: 10.17.4.24   |
+---------------------+

+---------------------+
|    OKD Worker 2     |
|    IP: 10.17.4.25   |
+---------------------+

+---------------------+
|    OKD Worker 3     |
|    IP: 10.17.4.26   |
+---------------------+

+---------------------+
|    FreeIPA Node     |
|    DNS, Identity    |
|    IP: 10.17.3.11   |
+---------------------+

+---------------------+
|   PostgreSQL Node   |
|   Database Server   |
|    IP: 10.17.3.13   |
+---------------------+

+---------------------+
|     Rook/Ceph       |
|  Persistent Storage |
+---------------------+



                                    +----------------------+
                                    |   Internet           |
                                    +----------+-----------+
                                               |
                                               |
                                      IP Pública (HTTPS, VPN, SSH)
                                               |
                                               |
                                    +----------v-----------+
                                    |   Router / Firewall   |
                                    +----------+-----------+
                                               |
                                               |
                                       +-------+-------+
                                       |   Bastion1    |
                                       |  (VPN, SSH)   |
                                       +-------+-------+
                                               |
                                               |
            +----------------------+-----------+-----------+---------------------+
            |                      |                       |                     |
            |                      |                       |                     |
+-----------v-----------+ +--------v--------+    +---------v---------+ +---------v--------+
|      FreeIPA1         | |  Load Balancer  |    |    PostgreSQL1    | |  Master Node 1  |
| (DNS, IdM) 10.17.3.11 | | (Traefik) 10.17.3.12|    |(DB) 10.17.3.13 | |  10.17.4.21     |
+-----------------------+ +------------------+    +------------------+ +-----------------+
                                                                |
                                                                |
                          +--------------------+ +--------------v--------------+
                          |    Master Node 2   | |      Master Node 3          |
                          |     10.17.4.22     | |       10.17.4.23            |
                          +--------------------+ +-----------------------------+
                                                                |
                                                                |
                          +--------------------+ +--------------v--------------+
                          |    Worker Node 1   | |      Worker Node 2          |
                          |     10.17.4.24     | |       10.17.4.25            |
                          +--------------------+ +-----------------------------+
                                                                |
                                                                |
                                            +-------------------v------------------+
                                            |             Worker Node 3            |
                                            |               10.17.4.26             |
                                            +--------------------------------------+


                                 +-------------------------------------------------------------+
                                 |                     Servidor Físico                         |
                                 |                ProLiant DL380 G7                            |
                                 +-------------------------------------------------------------+
                                   |  IP Pública: XXX.XXX.XXX.XXX
                                   |  IPs Privadas: 192.168.0.0/24
                                   |
                                   |-- Red br0 (Bridge Network)
                                   |   |-- Bastion Node (Rocky Linux 9.3 Minimal)
                                   |       |-- Función: Acceso seguro, VPN, SSH, Gestión de BD
                                   |       |-- Interfaz: enp3s0f1 - 192.168.0.20
                                   |
                                   |-- Red kube_network_02 (NAT Network)
                                   |   |-- FreeIPA Node (Rocky Linux 9.3)
                                   |   |     |-- Función: Servidor DNS y gestión de identidades
                                   |   |     |-- IP: 10.17.3.11
                                   |   |
                                   |   |-- Load Balancer Node (Rocky Linux 9.3)
                                   |   |     |-- Función: Balanceo de carga con Traefik
                                   |   |     |-- IP: 10.17.3.12
                                   |   |
                                   |   |-- PostgreSQL Node (Rocky Linux 9.3)
                                   |         |-- Función: Gestión de bases de datos
                                   |         |-- IP: 10.17.3.13
                                   |
                                   |-- Red kube_network_03 (NAT Network)
                                       |-- Bootstrap Node (Flatcar Container Linux)
                                       |     |-- Función: Inicialización del clúster
                                       |     |-- IP: 10.17.4.20
                                       |
                                       |-- Master Nodes (Flatcar Container Linux)
                                       |   |-- Master1
                                       |   |     |-- Función: Gestión del clúster
                                       |   |     |-- IP: 10.17.4.21
                                       |   |
                                       |   |-- Master2
                                       |   |     |-- Función: Gestión del clúster
                                       |   |     |-- IP: 10.17.4.22
                                       |   |
                                       |   |-- Master3
                                       |         |-- Función: Gestión del clúster
                                       |         |-- IP: 10.17.4.23
                                       |
                                       |-- Worker Nodes (Flatcar Container Linux)
                                           |-- Worker1
                                           |     |-- Función: Ejecución de aplicaciones
                                           |     |-- IP: 10.17.4.24
                                           |
                                           |-- Worker2
                                           |     |-- Función: Ejecución de aplicaciones
                                           |     |-- IP: 10.17.4.25
                                           |
                                           |-- Worker3
                                                 |-- Función: Ejecución de aplicaciones
                                                 |-- IP: 10.17.4.26

                                Red Pública:
                                 +--------------------------+
                                 | IP Pública               |
                                 |    XXX.XXX.XXX.XXX       |
                                 +-----------|--------------+
                                             |
                                 +-----------|--------------+
                                 |  VPN (WireGuard)         |
                                 |  Para acceso seguro SSH  |
                                 |  y gestión de BD         |
                                 +--------------------------+

                                Red Interna (NAT):
                                 +--------------------------+
                                 | Load Balancer (Traefik)  |
                                 | IP: 10.17.3.12           |
                                 |                          |
                                 |---+----------------------+
                                     |
                                 +---|----------------------+
                                 | Clúster OKD              |
                                 |                          |
                                 | Master Nodes:            |
                                 | - Master1: 10.17.4.21    |
                                 | - Master2: 10.17.4.22    |
                                 | - Master3: 10.17.4.23    |
                                 |                          |
                                 | Worker Nodes:            |
                                 | - Worker1: 10.17.4.24    |
                                 | - Worker2: 10.17.4.25    |
                                 | - Worker3: 10.17.4.26    |
                                 +--------------------------+

                                Salida HTTPS:
                                 +--------------------------+
                                 | IP Pública               |
                                 |    XXX.XXX.XXX.XXX       |
                                 +-----------|--------------+
                                             |
                                 +-----------|--------------+
                                 |  Servidor Web NGINX      |
                                 |  en el clúster OKD       |
                                 +--------------------------+



Descripción Detallada
Servidor Físico:

Modelo: ProLiant DL380 G7
IP Pública y Red Privada (192.168.0.0/24)
Ejecuta KVM con Libvirt y gestiona las máquinas virtuales.
Red br0 (Bridge Network):

Bastion Node:
Sistema operativo: Rocky Linux 9.3 Minimal
Función: Punto de acceso seguro, gestión de VPN, SSH, y base de datos.
Interfaz de red: enp3s0f1 (192.168.0.20)
Red kube_network_02 (NAT Network):

FreeIPA Node:
Sistema operativo: Rocky Linux 9.3
Función: Servidor DNS y gestión de identidades.
IP: 10.17.3.11
Load Balancer Node:
Sistema operativo: Rocky Linux 9.3
Función: Balanceo de carga usando Traefik.
IP: 10.17.3.12
PostgreSQL Node:
Sistema operativo: Rocky Linux 9.3
Función: Gestión de bases de datos.
IP: 10.17.3.13
Red kube_network_03 (NAT Network):

Bootstrap Node:
Sistema operativo: Flatcar Container Linux
Función: Inicialización del clúster.
IP: 10.17.4.20
Master Nodes:
Sistema operativo: Flatcar Container Linux
Función: Gestión del clúster.
IPs: 10.17.4.21, 10.17.4.22, 10.17.4.23
Worker Nodes:
Sistema operativo: Flatcar Container Linux
Función: Ejecución de aplicaciones.
IPs: 10.17.4.24, 10.17.4.25, 10.17.4.26
Red Pública y VPN:

Toda la comunicación segura, incluyendo SSH y gestión de bases de datos, se realiza a través de una VPN configurada con WireGuard en el Bastion Node.
Salida HTTPS:

La salida HTTPS de las aplicaciones web desplegadas en el clúster pasa por el servidor web NGINX en el clúster OKD y luego a través del balanceador de carga Traefik hacia la IP pública.
Con este diagrama y descripción, puedes visualizar la arquitectura completa del proyecto, incluyendo todas las tecnologías, máquinas virtuales, servidor físico y redes involucradas.


                                +-------------------------------------------------------------+
                                |                     Servidor Físico                         |
                                |                ProLiant DL380 G7                            |
                                +-------------------------------------------------------------+
                                  |  IP Pública: XXX.XXX.XXX.XXX
                                  |  IPs Privadas: 192.168.0.0/24
                                  |
                                  |-- Red br0 (Bridge Network)
                                  |   |-- Bastion Node (Rocky Linux 9.3 Minimal)
                                  |       |-- Función: Acceso seguro, VPN, SSH, Gestión de BD
                                  |       |-- Interfaz: enp3s0f1 - 192.168.0.20
                                  |
                                  |-- Red kube_network_02 (NAT Network)
                                  |   |-- FreeIPA Node (Rocky Linux 9.3)
                                  |   |     |-- Función: Servidor DNS y gestión de identidades
                                  |   |     |-- IP: 10.17.3.11
                                  |   |
                                  |   |-- Load Balancer Node (Rocky Linux 9.3)
                                  |   |     |-- Función: Balanceo de carga con Traefik
                                  |   |     |-- IP: 10.17.3.12
                                  |   |
                                  |   |-- PostgreSQL Node (Rocky Linux 9.3)
                                  |         |-- Función: Gestión de bases de datos
                                  |         |-- IP: 10.17.3.13
                                  |
                                  |-- Red kube_network_03 (NAT Network)
                                      |-- Bootstrap Node (Flatcar Container Linux)
                                      |     |-- Función: Inicialización del clúster
                                      |     |-- IP: 10.17.4.20
                                      |
                                      |-- Master Nodes (Flatcar Container Linux)
                                      |   |-- Master1
                                      |   |     |-- Función: Gestión del clúster
                                      |   |     |-- IP: 10.17.4.21
                                      |   |
                                      |   |-- Master2
                                      |   |     |-- Función: Gestión del clúster
                                      |   |     |-- IP: 10.17.4.22
                                      |   |
                                      |   |-- Master3
                                      |         |-- Función: Gestión del clúster
                                      |         |-- IP: 10.17.4.23
                                      |
                                      |-- Worker Nodes (Flatcar Container Linux)
                                          |-- Worker1
                                          |     |-- Función: Ejecución de aplicaciones
                                          |     |-- IP: 10.17.4.24
                                          |
                                          |-- Worker2
                                          |     |-- Función: Ejecución de aplicaciones
                                          |     |-- IP: 10.17.4.25
                                          |
                                          |-- Worker3
                                                |-- Función: Ejecución de aplicaciones
                                                |-- IP: 10.17.4.26

                                 Red Pública:
                                  +--------------------------+
                                  | IP Pública               |
                                  |    XXX.XXX.XXX.XXX       |
                                  +-----------|--------------+
                                              |
                                  +-----------|--------------+
                                  |  VPN (WireGuard)         |
                                  |  Para acceso seguro SSH  |
                                  |  y gestión de BD         |
                                  +--------------------------+

                                 Red Interna (NAT):
                                  +--------------------------+
                                  | Load Balancer (Traefik)  |
                                  | IP: 10.17.3.12           |
                                  |                          |
                                  |---+----------------------+
                                      |
                                  +---|----------------------+
                                  | Clúster OKD              |
                                  |                          |
                                  | Master Nodes:            |
                                  | - Master1: 10.17.4.21    |
                                  | - Master2: 10.17.4.22    |
                                  | - Master3: 10.17.4.23    |
                                  |                          |
                                  | Worker Nodes:            |
                                  | - Worker1: 10.17.4.24    |
                                  | - Worker2: 10.17.4.25    |
                                  | - Worker3: 10.17.4.26    |
                                  +--------------------------+

                                 Salida HTTPS:
                                  +--------------------------+
                                  | IP Pública               |
                                  |    XXX.XXX.XXX.XXX       |
                                  +-----------|--------------+
                                              |
                                  +-----------|--------------+
                                  |  Servidor Web NGINX      |
                                  |  en el clúster OKD       |
                                  +--------------------------+



__
                                +-------------------------------------------------------------+
                                |                     Servidor Físico                         |
                                |                ProLiant DL380 G7                            |
                                +-------------------------------------------------------------+
                                  |  IP Pública: XXX.XXX.XXX.XXX
                                  |  IPs Privadas: 192.168.0.0/24
                                  |
                                  |-- Red br0 (Bridge Network)
                                  |   |-- Bastion Node (Rocky Linux 9.3 Minimal)
                                  |       |-- Función: Acceso seguro, VPN, SSH, Gestión de BD
                                  |       |-- Interfaz: enp3s0f1 - 192.168.0.20
                                  |
                                  |-- Red kube_network_02 (NAT Network)
                                  |   |-- FreeIPA Node (Rocky Linux 9.3)
                                  |   |     |-- Función: Servidor DNS y gestión de identidades
                                  |   |     |-- IP: 10.17.3.11
                                  |   |
                                  |   |-- Load Balancer Node (Rocky Linux 9.3)
                                  |   |     |-- Función: Balanceo de carga con Traefik
                                  |   |     |-- IP: 10.17.3.12
                                  |   |
                                  |   |-- PostgreSQL Node (Rocky Linux 9.3)
                                  |         |-- Función: Gestión de bases de datos
                                  |         |-- IP: 10.17.3.13
                                  |
                                  |-- Red kube_network_03 (NAT Network)
                                      |-- Bootstrap Node (Flatcar Container Linux)
                                      |     |-- Función: Inicialización del clúster
                                      |     |-- IP: 10.17.4.20
                                      |
                                      |-- Master Nodes (Flatcar Container Linux)
                                      |   |-- Master1
                                      |   |     |-- Función: Gestión del clúster
                                      |   |     |-- IP: 10.17.4.21
                                      |   |
                                      |   |-- Master2
                                      |   |     |-- Función: Gestión del clúster
                                      |   |     |-- IP: 10.17.4.22
                                      |   |
                                      |   |-- Master3
                                      |         |-- Función: Gestión del clúster
                                      |         |-- IP: 10.17.4.23
                                      |
                                      |-- Worker Nodes (Flatcar Container Linux)
                                          |-- Worker1
                                          |     |-- Función: Ejecución de aplicaciones
                                          |     |-- IP: 10.17.4.24
                                          |
                                          |-- Worker2
                                          |     |-- Función: Ejecución de aplicaciones
                                          |     |-- IP: 10.17.4.25
                                          |
                                          |-- Worker3
                                                |-- Función: Ejecución de aplicaciones
                                                |-- IP: 10.17.4.26

                                 Red Pública:
                                  +--------------------------+
                                  | IP Pública               |
                                  |    XXX.XXX.XXX.XXX       |
                                  +-----------|--------------+
                                              |
                                  +-----------|--------------+
                                  |  VPN (WireGuard)         |
                                  |  Para acceso seguro SSH  |
                                  |  y gestión de BD         |
                                  +--------------------------+

                                 Red Interna (NAT):
                                  +--------------------------+
                                  | Load Balancer (Traefik)  |
                                  | IP: 10.17.3.12           |
                                  |                          |
                                  |---+----------------------+
                                      |
                                  +---|----------------------+
                                  | Clúster OKD              |
                                  |                          |
                                  | Master Nodes:            |
                                  | - Master1: 10.17.4.21    |
                                  | - Master2: 10.17.4.22    |
                                  | - Master3: 10.17.4.23    |
                                  |                          |
                                  | Worker Nodes:            |
                                  | - Worker1: 10.17.4.24    |
                                  | - Worker2: 10.17.4.25    |
                                  | - Worker3: 10.17.4.26    |
                                  +--------------------------+

                                 Salida HTTPS:
                                  +--------------------------+
                                  | IP Pública               |
                                  |    XXX.XXX.XXX.XXX       |
                                  +-----------|--------------+
                                              |
                                  +-----------|--------------+
                                  |  Servidor Web NGINX      |
                                  |  en el clúster OKD       |
                                  +--------------------------+
