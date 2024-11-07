Configuración de un Puente de Red en Rocky Linux

Introducción
Este documento detalla los pasos para configurar un puente de red en un servidor Rocky Linux. El puente permitirá que las máquinas virtuales (VMs) se comuniquen entre sí y con redes externas, utilizando un enfoque centralizado y eficiente.

Paso 1: Instalación de Paquetes Necesarios
Para manejar puentes en Linux, es necesario el paquete bridge-utils. Instálalo con el siguiente comando:

bash
Copiar código
sudo dnf install bridge-utils
Paso 2: Configuración del Puente de Red
La configuración del puente se realiza a través de archivos en /etc/sysconfig/network-scripts/. Para configurar un puente llamado br0, edita o crea el archivo ifcfg-br0:

ini
Copiar código
DEVICE=br0
TYPE=Bridge
BOOTPROTO=static
IPADDR=192.168.0.27
PREFIX=24
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
ONBOOT=yes
Este archivo asigna una dirección IP estática al puente y lo configura para que se active al iniciar el sistema.

Paso 3: Configuración de Interfaces de Red para el Puente
Cada interfaz física que desees incluir en el puente, como enp3s0f0, debe configurarse para asociarse con br0. Edita el archivo correspondiente:

ini
Copiar código
DEVICE=enp3s0f0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br0
Paso 4: Reiniciar los Servicios de Red
Para aplicar los cambios, reinicia los servicios de red con uno de los siguientes comandos:

bash
Copiar código
sudo systemctl restart NetworkManager
o

bash
Copiar código
sudo systemctl restart network
Paso 5: Verificación de la Configuración del Puente
Verifica que el puente esté correctamente configurado con:

bash
Copiar código
ip addr show br0
Este comando mostrará la información de la IP asignada al puente y otras configuraciones relevantes.

Integración con Libvirt y KVM
Asegúrate de que libvirt esté configurado para utilizar este puente. Al crear una VM, especifica br0 como la interfaz de red. Esto permitirá que las VMs utilicen el puente para su comunicación de red.

Consideraciones Finales
Verifica cada paso y confirma que todas las configuraciones se apliquen correctamente.
Asegúrate de que las interfaces mencionadas (eth0, br0) coincidan con las disponibles y correctas en tu servidor.
Puedes verificar las interfaces disponibles con ip link show.
Estos pasos deben realizarse como usuario root o utilizando sudo para garantizar que tienes los permisos necesarios.
Configuración de Cloud-init para la Máquina Virtual
Interfaz de Red Virtual en la Máquina Virtual
La interfaz en la máquina virtual no debe tener una dirección IP configurada directamente si está siendo manejada por un puente (br0) que ya posee una configuración IP.

Configura la interfaz de la máquina virtual en cloud-init usando write_files para insertar el archivo de configuración:

yaml
Copiar código
write_files:
  - path: /etc/sysconfig/network-scripts/ifcfg-eth0
    owner: root:root
    permissions: '0644'
    content: |
      TYPE=Ethernet
      DEVICE=eth0
      ONBOOT=yes
      BOOTPROTO=none
      NM_CONTROLLED=yes
      BRIDGE=br0
Reinicio de NetworkManager (Opcional)
Para aplicar configuraciones, es posible que necesites reiniciar NetworkManager:

yaml
Copiar código
runcmd:
  - ['systemctl', 'restart', 'NetworkManager.service']
Estas configuraciones aseguran que tu máquina virtual se configure correctamente para operar a través del puente br0 establecido en el servidor físico.




[victory@server ~]$ ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp3s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
3: enp3s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 2c:76:8a:ac:de:be brd ff:ff:ff:ff:ff:ff
4: enp4s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 2c:76:8a:ac:de:c0 brd ff:ff:ff:ff:ff:ff
5: enp4s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 2c:76:8a:ac:de:c2 brd ff:ff:ff:ff:ff:ff
6: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether b6:36:16:33:c8:bc brd ff:ff:ff:ff:ff:ff
7: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether b6:55:a9:f8:be:43 brd ff:ff:ff:ff:ff:ff
[victory@server ~]$ lspci | grep Ethernet
03:00.0 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
03:00.1 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.0 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
04:00.1 Ethernet controller: Broadcom Inc. and subsidiaries NetXtreme II BCM5709 Gigabit Ethernet (rev 20)
[victory@server ~]$ ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: enp3s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.16/24 brd 192.168.0.255 scope global dynamic noprefixroute enp3s0f0
       valid_lft 81942sec preferred_lft 81942sec
    inet6 fe80::2e76:8aff:feac:debc/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
3: enp3s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:be brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.24/24 brd 192.168.0.255 scope global dynamic noprefixroute enp3s0f1
       valid_lft 81940sec preferred_lft 81940sec
    inet6 fe80::2e76:8aff:feac:debe/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
4: enp4s0f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:c0 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.20/24 brd 192.168.0.255 scope global dynamic noprefixroute enp4s0f0
       valid_lft 81937sec preferred_lft 81937sec
    inet6 fe80::2e76:8aff:feac:dec0/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
5: enp4s0f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:c2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.18/24 brd 192.168.0.255 scope global dynamic noprefixroute enp4s0f1
       valid_lft 81939sec preferred_lft 81939sec
    inet6 fe80::2e76:8aff:feac:dec2/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
6: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether b6:36:16:33:c8:bc brd ff:ff:ff:ff:ff:ff
7: br0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether b6:55:a9:f8:be:43 brd ff:ff:ff:ff:ff:ff
[victory@server ~]$ ipconfig
-bash: ipconfig: orden no encontrada
[victory@server ~]$ ifconfig
enp3s0f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.16  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::2e76:8aff:feac:debc  prefixlen 64  scopeid 0x20<link>
        ether 2c:76:8a:ac:de:bc  txqueuelen 1000  (Ethernet)
        RX packets 2457  bytes 257324 (251.2 KiB)
        RX errors 0  dropped 1  overruns 0  frame 0
        TX packets 31  bytes 4274 (4.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp3s0f1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.24  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::2e76:8aff:feac:debe  prefixlen 64  scopeid 0x20<link>
        ether 2c:76:8a:ac:de:be  txqueuelen 1000  (Ethernet)
        RX packets 2476  bytes 261860 (255.7 KiB)
        RX errors 0  dropped 1  overruns 0  frame 0
        TX packets 32  bytes 4478 (4.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp4s0f0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.20  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::2e76:8aff:feac:dec0  prefixlen 64  scopeid 0x20<link>
        ether 2c:76:8a:ac:de:c0  txqueuelen 1000  (Ethernet)
        RX packets 4556  bytes 450102 (439.5 KiB)
        RX errors 0  dropped 1  overruns 0  frame 0
        TX packets 1590  bytes 218275 (213.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

enp4s0f1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.0.18  netmask 255.255.255.0  broadcast 192.168.0.255
        inet6 fe80::2e76:8aff:feac:dec2  prefixlen 64  scopeid 0x20<link>
        ether 2c:76:8a:ac:de:c2  txqueuelen 1000  (Ethernet)
        RX packets 2475  bytes 261985 (255.8 KiB)
        RX errors 0  dropped 1  overruns 0  frame 0
        TX packets 32  bytes 4478 (4.3 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 10  bytes 1570 (1.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 10  bytes 1570 (1.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0



Verificar el Módulo del Kernel: Asegúrate de que todos los módulos necesarios para el funcionamiento del networking de puentes estén cargados. Ya has cargado br_netfilter, pero también verifica si necesitas otros relacionados con la virtualización como vhost_net:

bash
Copiar código
sudo modprobe vhost_net
Permisos y Políticas de Seguridad: Verifica las políticas de SELinux o AppArmor para asegurarte de que no están bloqueando las operaciones de Libvirt. Puedes temporalmente poner SELinux en modo permisivo para descartar esto como causa:

bash
Copiar código
sudo setenforce 0
Revisa los logs de SELinux si encuentras denegaciones relacionadas con libvirt o qemu.


write_files:
  - path: /etc/sysconfig/network-scripts/ifcfg-eth0
    owner: root:root
    permissions: '0644'
    content: |
      TYPE=Ethernet
      DEVICE=eth0
      ONBOOT=yes
      BOOTPROTO=none
      NM_CONTROLLED=yes
      BRIDGE=br0
      IPADDR=192.168.0.27
      PREFIX=24
      GATEWAY=192.168.0.1
      DNS1=8.8.8.8
      DNS2=8.8.4.4
      IPV4_FAILURE_FATAL=no
      IPV6INIT=no


  /etc/sysconfig/network-scripts/


  [victory@server ~]$ brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.2c768aacdebc       no              enp3s0f0
                                                        vnet4
k8s             8000.52540041a05d       yes
virbr0          8000.525400bef6d5       yes
[victory@server ~]$ sudo brctl show
[sudo] password for victory:
bridge name     bridge id               STP enabled     interfaces
br0             8000.2c768aacdebc       no              enp3s0f0
                                                        vnet4
k8s             8000.52540041a05d       yes
virbr0          8000.525400bef6d5       yes
[victory@server ~]$



resource "libvirt_network" "kube_network_01" {
  name   = "kube_network_01"
  mode   = "bridge"
  bridge = "br0" 
  addresses = ["192.168.0.27/24"]

}


network_interface {
    network_id     = libvirt_network.kube_network_01.id
    wait_for_lease = true
    addresses      = [each.value.ip]
  }



resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}











