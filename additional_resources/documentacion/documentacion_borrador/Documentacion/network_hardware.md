
# Documentación del Entorno de Red y Servidor

## Hardware del Servidor
- **Modelo**: ProLiant DL380 G7
- **CPU**: Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU**: AMD ATI 01:03.0 ES1000
- **Memoria**: 1093MiB / 35904MiB
- **Almacenamiento**:
  - Disco Duro Principal: 1.5TB
  - Disco Duro Secundario: 3.0TB

## Sistemas Operativos y Virtualización
- **Rocky Linux 9.3 (Blue Onyx)**
- **rocky linux minimal**
- **KVM con Libvirt**: kvm/qemu y libvirt y Virt-Manager
- **Flatcar Container Linux**

## Configuración de Red
- **Open vSwitch**: Gestión de redes virtuales y VLANs (opcional)
- **VPN con WireGuard**
- **IP Pública**
- **DHCP en KVM**
- **Firewall**
- **Modo NAT y Bridge**

## Interfaces Físicas de Red y Funcionalidad
| Interface | IP Address      | Netmask         | Broadcast        | Description                              | Additional Info                   |
|-----------|-----------------|-----------------|------------------|------------------------------------------|-----------------------------------|
| enp3s0f0  | 192.168.0.15    | 255.255.255.0   | 192.168.0.255    | Interfaz general del servidor            | -                                 |
| enp3s0f1  | 192.168.0.16    | 255.255.255.0   | 192.168.0.255    | Utilizada para Bridge en el nodo bastion1| -                                 |
| enp4s0f0  | 192.168.0.20    | 255.255.255.0   | 192.168.0.255    | Otra interfaz general del servidor       | -                                 |
| enp4s0f1  | 192.168.0.18    | 255.255.255.0   | 192.168.0.255    | Reserva o conexión redundante            | -                                 |


## Tabla de Configuración de Redes

### kube_network_01 - Bridge Network
| Red NAT          | Nodos      | Dirección IP | Rol del Nodo                               | Interfaz de Red |
|------------------|------------|--------------|--------------------------------------------|-----------------|
| kube_network_01  | bastion1   |              | Acceso seguro, Punto de conexión de bridge | enp3s0f1        |

### kube_network_02 - NAT Network
| Red NAT          | Nodos               | Dirección IP | Rol del Nodo                       | Interfaz de Red |
|------------------|---------------------|--------------|------------------------------------|-----------------|
| kube_network_02  | freeipa1            | 10.17.3.11   | Servidor de DNS y gestión de identidades | Virtual - NAT  |
| kube_network_02  | load_balancer1      | 10.17.3.12   | Balanceo de carga para el clúster  | Virtual - NAT   |
| kube_network_02  | postgresql1         | 10.17.3.13   | Gestión de bases de datos          | Virtual - NAT   |

### kube_network_03 - NAT Network
| Red NAT          | Nodos               | Dirección IP | Rol del Nodo               | Interfaz de Red |
|------------------|---------------------|--------------|----------------------------|-----------------|
| kube_network_03  | bootstrap1          | 10.17.4.20   | Inicialización del clúster | Virtual - NAT   |
| kube_network_03  | master1             | 10.17.4.21   | Gestión del clúster        | Virtual - NAT   |
| kube_network_03  | master2             | 10.17.4.22   | Gestión del clúster        | Virtual - NAT   |
| kube_network_03  | master3             | 10.17.4.23   | Gestión del clúster        | Virtual - NAT   |
| kube_network_03  | worker1             | 10.17.4.24   | Ejecución de aplicaciones  | Virtual - NAT   |
| kube_network_03  | worker2             | 10.17.4.25   | Ejecución de aplicaciones  | Virtual - NAT   |
| kube_network_03  | worker3             | 10.17.4.26   | Ejecución de aplicaciones  | Virtual - NAT   |

### Recursos Terraform para la configuración de redes
```hcl
# Red kube_network_01 - Bridge Network
resource "libvirt_network" "kube_network_01" {
  name   = "kube_network_01"
  mode   = "bridge"
  bridge = "br0"
}

# Red kube_network_02 - NAT Network
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}

# Red kube_network_03 - NAT Network
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  addresses = ["10.17.4.0/24"]
}

