# Documentación Técnica para Configuración de Comunicación entre Redes NAT y una Red Bridge en KVM

Este documento proporciona una guía detallada sobre cómo configurar la comunicación entre redes NAT y una red puente (bridge) en un entorno KVM. La configuración se realiza en un servidor KVM físico y sus máquinas virtuales (VMs).

## 1. Configuración de la Red Bridge (Bridge Network)

### Paso 1: Asegurar que la Red Bridge esté Configurada y Funcionando

La red bridge (br0) debe estar configurada y operativa. En tu configuración de Terraform, esto se ha definido como:

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

2. Habilitar el Reenvío de IP en el Servidor KVM

El reenvío de IP debe estar habilitado en el servidor KVM para permitir la comunicación entre las redes NAT y la red bridge.

### Paso 2: Editar el Archivo `sysctl.conf`

En el servidor KVM físico (Servidor KVM: ProLiant DL380 G7), edita el archivo `/etc/sysctl.conf` y añade la siguiente línea:

```bash
net.ipv4.ip_forward = 1
```

### Paso 3: Aplicar los Cambios

Ejecuta el siguiente comando para aplicar los cambios:

```bash
sudo sysctl -p
```

1. Configurar el Enrutamiento entre las Redes

Necesitarás agregar las reglas de enrutamiento necesarias para permitir la comunicación entre las redes NAT y la red bridge utilizando iptables.

### Paso 4: Agregar Reglas de Enrutamiento

Configuración para nat_network_02

En el servidor KVM físico:

```bash
sudo iptables -t nat -A POSTROUTING -s 10.17.3.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
```

Configuración para nat_network_03

En el servidor KVM físico:

```bash
sudo iptables -t nat -A POSTROUTING -s 10.17.4.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr1 -o br0 -j ACCEPT
```

1. Persistir las Reglas de iptables

Para asegurar que las reglas de iptables se mantengan después de un reinicio, utiliza iptables-save y iptables-restore.

### Paso 5: Guardar las Reglas Actuales

En el servidor KVM físico:

```bash
sudo mkdir -p /etc/iptables
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

### Paso 6: Configurar la Restauración de las Reglas al Inicio

Opción 1: Usar un Script de Inicio



Añade las siguientes líneas al script:

```bash
#!/bin/
/sbin/iptables-restore < /etc/iptables/rules.v4
```

sudo systemctl enable ip6tables
sudo systemctl start ip6tables
sudo systemctl status ip6tables

Guarda el archivo y hazlo ejecutable:


5. Configurar las Rutas en las Máquinas Virtuales

Asegúrate de que las máquinas virtuales en las redes NAT sepan cómo llegar a la red bridge. Esto generalmente implica agregar rutas estáticas en las máquinas virtuales.

### Paso 7: Agregar Rutas Estáticas

Ejemplo en una Máquina Virtual en nat_network_02

En la VM freeipa1:

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
```

Aquí, 10.17.3.1 es la puerta de enlace de la red NAT nat_network_02.

1. Verificar la Conectividad
Finalmente, verifica la conectividad entre las máquinas virtuales en las redes NAT y la red bridge utilizando herramientas como ping.

### Paso 8: Comprobar la Conexión

En la VM freeipa1 en nat_network_02:

```bash
ping 192.168.0.35
```

Este comando debería hacer ping a la IP del nodo bastión bastion1 en la red bridge br0.

### Resumen

Para lograr la comunicación entre redes NAT y la red bridge (bridge) en tu entorno KVM, debes:

Configurar correctamente la red bridge (br0).

Habilitar el reenvío de IP en el servidor KVM.

Configurar las reglas de iptables para enmascarar y permitir el tráfico entre las redes.
Persistir las reglas de iptables.

Agregar las rutas necesarias en las máquinas virtuales.
Verificar la conectividad.

Siguiendo estos pasos, podrás establecer comunicación entre tus redes NAT y la red bridge en tu entorno KVM.

Para cualquier duda o problema, por favor, abre un issue en el repositorio o contacta al mantenedor del proyecto.

Mantenedor del Proyecto: Victor Galvez


## kube_network_02

- freeipa1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
```

## kube_network_02

- load_balancer1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
```

- postgresql1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
```

## kube_network_03

- bootstrap1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- master1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- master2

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- master3

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- worker1

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- worker2

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

- worker3

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```






[victory@server terraform-openshift-kvm-deployment]$ cat /etc/iptables/rules.v4
# Generated by iptables-save v1.8.10 (nf_tables) on Wed May 22 20:19:36 2024
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [3332:6338623]
:LIBVIRT_PRT - [0:0]
-A POSTROUTING -j LIBVIRT_PRT
-A LIBVIRT_PRT -o virbr1 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
-A LIBVIRT_PRT -o virbr0 -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
COMMIT
# Completed on Wed May 22 20:19:36 2024
# Generated by iptables-save v1.8.10 (nf_tables) on Wed May 22 20:19:36 2024
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
# Completed on Wed May 22 20:19:36 2024
# Generated by iptables-save v1.8.10 (nf_tables) on Wed May 22 20:19:36 2024
*filter
:INPUT ACCEPT [4781:455805]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [3330:6338471]
:LIBVIRT_FWI - [0:0]
:LIBVIRT_FWO - [0:0]
:LIBVIRT_FWX - [0:0]
:LIBVIRT_INP - [0:0]
:LIBVIRT_OUT - [0:0]
-A INPUT -j LIBVIRT_INP
-A FORWARD -j LIBVIRT_FWX
-A FORWARD -j LIBVIRT_FWI
-A FORWARD -j LIBVIRT_FWO
-A OUTPUT -j LIBVIRT_OUT
-A LIBVIRT_FWI -d 10.17.4.0/24 -o virbr1 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A LIBVIRT_FWI -o virbr1 -j REJECT --reject-with icmp-port-unreachable
-A LIBVIRT_FWI -d 10.17.3.0/24 -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A LIBVIRT_FWI -o virbr0 -j REJECT --reject-with icmp-port-unreachable
-A LIBVIRT_FWO -s 10.17.4.0/24 -i virbr1 -j ACCEPT
-A LIBVIRT_FWO -i virbr1 -j REJECT --reject-with icmp-port-unreachable
-A LIBVIRT_FWO -s 10.17.3.0/24 -i virbr0 -j ACCEPT
-A LIBVIRT_FWO -i virbr0 -j REJECT --reject-with icmp-port-unreachable
-A LIBVIRT_FWX -i virbr1 -o virbr1 -j ACCEPT
-A LIBVIRT_FWX -i virbr0 -o virbr0 -j ACCEPT
-A LIBVIRT_INP -i virbr1 -p udp -m udp --dport 53 -j ACCEPT
-A LIBVIRT_INP -i virbr1 -p tcp -m tcp --dport 53 -j ACCEPT
-A LIBVIRT_INP -i virbr1 -p udp -m udp --dport 67 -j ACCEPT
-A LIBVIRT_INP -i virbr1 -p tcp -m tcp --dport 67 -j ACCEPT
-A LIBVIRT_INP -i virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A LIBVIRT_INP -i virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A LIBVIRT_INP -i virbr0 -p udp -m udp --dport 67 -j ACCEPT
-A LIBVIRT_INP -i virbr0 -p tcp -m tcp --dport 67 -j ACCEPT
-A LIBVIRT_OUT -o virbr1 -p udp -m udp --dport 53 -j ACCEPT
-A LIBVIRT_OUT -o virbr1 -p tcp -m tcp --dport 53 -j ACCEPT
-A LIBVIRT_OUT -o virbr1 -p udp -m udp --dport 68 -j ACCEPT
-A LIBVIRT_OUT -o virbr1 -p tcp -m tcp --dport 68 -j ACCEPT
-A LIBVIRT_OUT -o virbr0 -p udp -m udp --dport 53 -j ACCEPT
-A LIBVIRT_OUT -o virbr0 -p tcp -m tcp --dport 53 -j ACCEPT
-A LIBVIRT_OUT -o virbr0 -p udp -m udp --dport 68 -j ACCEPT
-A LIBVIRT_OUT -o virbr0 -p tcp -m tcp --dport 68 -j ACCEPT
COMMIT
# Completed on Wed May 22 20:19:36 2024
# Generated by iptables-save v1.8.10 (nf_tables) on Wed May 22 20:19:36 2024
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:LIBVIRT_PRT - [0:0]
-A POSTROUTING -j LIBVIRT_PRT
-A LIBVIRT_PRT -s 10.17.4.0/24 -d 224.0.0.0/24 -j RETURN
-A LIBVIRT_PRT -s 10.17.4.0/24 -d 255.255.255.255/32 -j RETURN
-A LIBVIRT_PRT -s 10.17.4.0/24 ! -d 10.17.4.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
-A LIBVIRT_PRT -s 10.17.4.0/24 ! -d 10.17.4.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
-A LIBVIRT_PRT -s 10.17.4.0/24 ! -d 10.17.4.0/24 -j MASQUERADE
-A LIBVIRT_PRT -s 10.17.3.0/24 -d 224.0.0.0/24 -j RETURN
-A LIBVIRT_PRT -s 10.17.3.0/24 -d 255.255.255.255/32 -j RETURN
-A LIBVIRT_PRT -s 10.17.3.0/24 ! -d 10.17.3.0/24 -p tcp -j MASQUERADE --to-ports 1024-65535
-A LIBVIRT_PRT -s 10.17.3.0/24 ! -d 10.17.3.0/24 -p udp -j MASQUERADE --to-ports 1024-65535
-A LIBVIRT_PRT -s 10.17.3.0/24 ! -d 10.17.3.0/24 -j MASQUERADE
COMMIT

# Completed on Wed May 22 20:19:36 2024

[victory@server terraform-openshift-kvm-deployment]$