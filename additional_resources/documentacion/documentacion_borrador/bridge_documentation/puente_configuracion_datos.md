# Configuracion de puente de red en Rocky Linux 9 con NetworkManager KVM y libvirt y terrafom , y cloud init 

quiero que la maquina virtual tenga una configuracion de red estatica y que se conecte a la red a traves de un puente de red.
con la ip 192.168.0.35 y que tenga acceso a internet. y salidas a internet.

# Hardware del Servidor

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

### Especificaciones de Almacenamiento y Memoria

- **Configuración de Disco y Particiones**:
  - **/dev/sda**: 3.27 TiB
  - **/dev/sdb**: 465.71 GiB
- **Particiones**:
  - **/dev/sda1**: Sistema
  - **/dev/sda2**: 2 GB Linux Filesystem
  - **/dev/sda3**: ~2.89 TiB Linux Filesystem
- **Uso de Memoria**:
  - **Total Memory**: 35GiB
  - **Free Memory**: 33GiB
  - **Swap**: 17GiB
- **Uso del Filesystem**:
  - **/dev/mapper/rl-root**: 100G (7.5G usado)
  - **/dev/sda2**: 1014M (718M usado)
  - **/dev/mapper/rl-home**: 3.0T (25G usado)
  

### Interfaces de Red Identificadas

ips son de ejemplo dhscp de las interfaces de red en el servidor fisico

- **enp3s0f0**: 192.168.0.15 +
- **enp3s0f1**: 192.168.0.16  (utilizada para Bridge en Bastion Node)
- **enp4s0f0**: 192.168.0.20 
- **enp4s0f1**: 192.168.0.18 
- **lo (Loopback)**: 127.0.0.1


- **configuracion de red en Rocky Linux 9 servidor fisico con NetworkManager KVM y libvirt cloud init**

```bash
cat /etc/sysconfig/network-scripts/ifcfg-br0
```

```plaintext
# /etc/sysconfig/network-scripts/ifcfg-br0
DEVICE=br0
TYPE=Bridge
BOOTPROTO=static
IPADDR=192.168.0.35
PREFIX=24
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
ONBOOT=yes
```

```bash
cat /etc/sysconfig/network-scripts/ifcfg-enp3s0f0
```

```plaintext
# /etc/sysconfig/network-scripts/ifcfg-enp3s0f0
DEVICE=enp3s0f0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br0
```

```bash
cat /etc/NetworkManager/conf.d/br0.conf
```

```plaintext
[device]
match-device=br0
```

```bash
cat /etc/NetworkManager/10-globally-managed-devices.conf
```

```plaintext
[keyfile]
unmanaged-devices=none
```

```bash
cat /etc/NetworkManager/NetworkManager.conf
```

```plaintext
[main]
plugins=keyfile,ifcfg-rh
```

```plaintext
    [logging]
level=DEBUG
domains=ALL
```

```bash
    sudo systemctl restart NetworkManager
```


# ver interfaces de red físicas
  
  ```bash
lspci | grep Ethernet
03:00.0 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
03:00.1 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.0 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.1 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
  ```

  ```bash
  ip addr show
  ```
  - output
  - 
  ```plaintext
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp3s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq master br0 state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
3: enp3s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:be brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.42/24 brd 192.168.0.255 scope global dynamic noprefixroute enp3s0f1
       valid_lft 83933sec preferred_lft 83933sec
    inet6 fe80::3ea:56ab:10ce:d224/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: enp4s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.20/24 brd 192.168.0.255 scope global dynamic noprefixroute enp4s0f0
       valid_lft 83929sec preferred_lft 83929sec
    inet6 fe80::863b:199b:d2f:4b44/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
5: enp4s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:c2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.18/24 brd 192.168.0.255 scope global dynamic noprefixroute enp4s0f1
       valid_lft 83933sec preferred_lft 83933sec
    inet6 fe80::4a8b:91ce:d9d5:6440/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.35/24 brd 192.168.0.255 scope global noprefixroute br0
       valid_lft forever preferred_lft forever
    inet6 fe80::3b35:9829:337b:7e44/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
7: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:be:f6:d5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
8: k8s: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:41:a0:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.120.1/24 brd 192.168.120.255 scope global k8s
       valid_lft forever preferred_lft forever
9: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br0 state UNKNOWN group default qlen 1000
    link/ether fe:54:00:3e:a3:78 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::fc54:ff:fe3e:a378/64 scope link
       valid_lft forever preferred_lft forever
  ```plaintext


# Maquina Virtual configuracion red  cloud init

\config\bastion1-user-data.tpl

base64
configuracion red cloud init maquina virtual en el archivo de configuracion de cloud init

 cat /etc/sysconfig/network-scripts/ifcfg-eth0

 \config\bastion1-user-data.tpl

```yaml
TYPE=Ethernet
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br0
NM_CONTROLLED=yes
IPADDR=192.168.0.35
PREFIX=24
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
IPV4_FAILURE_FATAL=no
IPV6INIT=no
DEFROUTE="yes"
BROWSER_ONLY="no"
PROXY_METHOD="none"
```

base64
 \config\bastion1-user-data.tpl





sudo virsh net-list --all
 Nombre            Estado   Inicio automático   Persistente
-------------------------------------------------------------
 default           activo   si                  si
 k8s-network       activo   si                  si
 kube_network_01   activo   si                  si

sudo virsh net-dhcp-leases  kube_network_01


tree

├── config
│   ├── bastion1-user-data.tpl
│   └── network-config.tpl
├── main.tf
├── terraform.tfvars
└── variables.tf



sudo nmcli con show br0
sudo virsh net-list --all
sudo virsh net-start default
sudo virsh net-autostart default
sudo virsh net-list --all
sudo virsh list --all
sudo nmcli con mod br0 ipv4.addresses "192.168.0.35/24" ipv4.gateway "192.168.0.1" ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli con up br0
 mv-01-bastion1-cloud-init_kvm_rocky_linux_libvirt]$ sudo nmcli con mod br0 ipv4.addresses "192.168.0.35/24" ipv4.gateway "192.168.0.1" ipv4.dns "8.8.8.8,8.8.4.4"
 mv-01-bastion1-cloud-init_kvm_rocky_linux_libvirt]$ sudo nmcli con up br0
La conexión se ha activado correctamente (master waiting for slaves) (ruta activa D-Bus: /org/freedesktop/NetworkManager/ActiveConnection/10)
 mv-01-bastion1-cloud-init_kvm_rocky_linux_libvirt]$


sudo nmcli connection up br0
sudo brctl addif br0 enp3s0f0
sudo systemctl restart NetworkManager
sudo systemctl restart NetworkManager
sudo systemctl restart libvirtd
sudo systemctl restart NetworkManager
ip addr show br0
sudo brctl addif br0 enp3s0f0
sudo systemctl restart NetworkManager
sudo systemctl restart libvirtd
journalctl -u NetworkManager
journalctl -u libvirtd
ip addr show eth0
ping -c 4 google.com
sudo nmcli con mod br0 ipv4.addresses "192.168.0.35/24"
sudo nmcli con mod br0 ipv4.gateway "192.168.0.1"
sudo nmcli con mod br0 ipv4.dns "8.8.8.8,8.8.4.4"
sudo nmcli con mod br0 ipv4.method manual
sudo systemctl restart NetworkManager
sudo nmcli connection show




sudo nmcli con show br0

sudo nmcli con show br0


sudo ip link add name br0 type bridge
sudo ip link set br0 up
