
Instalación de Herramientas Necesarias:

Primero, instala las herramientas necesarias para gestionar puentes e interfaces de red. En Rocky Linux, puedes hacer esto utilizando el gestor de paquetes dnf. Ejecuta el siguiente comando en la terminal:

```bash
sudo dnf install bridge-utils net-tools
```
Configuración del Puente de Red:
Crea un archivo de configuración para el puente de red en /etc/sysconfig/network-scripts/. Puedes nombrar este archivo ifcfg-br0. Utiliza un editor de texto como vim o nano para crear y editar el archivo:

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-br0
```
Configuración del Archivo ifcfg-br0:

Dentro del archivo ifcfg-br0, añade el siguiente contenido:

```bash
DEVICE=br0
TYPE=Bridge
BOOTPROTO=static
IPADDR=TU_IP_ESTÁTICA
PREFIX=TU_PREFIJO_DE_RED
GATEWAY=TU_PUERTA_DE_ENLACE
DNS1=TU_DNS_PRIMARIO
DNS2=TU_DNS_SECUNDARIO
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
ONBOOT=yes
NM_CONTROLLED=no
DELAY=0
```
Configuración de la Interfaz Física:
Ahora, necesitas configurar la interfaz física que se utilizará como parte del puente. Para ello, crea o edita el archivo correspondiente en el mismo directorio (/etc/sysconfig/network-scripts/). Por ejemplo, si tu interfaz física es enp3s0f0, el archivo sería ifcfg-enp3s0f0. Edita este archivo y asegúrate de que tenga una línea que haga referencia al puente br0. Debería verse algo así:

```bash
DEVICE=enp3s0f0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br0
```
Reinicio de los Servicios de Red:
Para aplicar los cambios, reinicia los servicios de red. Puedes hacerlo ejecutando el siguiente comando:

```bash

sudo systemctl restart NetworkManager
Verificación de la Configuración del Puente:
Verifica que el puente esté correctamente configurado y operativo ejecutando el siguiente comando:

```bash

ip addr show br0
Con estos pasos, habrás creado un puente de red en Rocky Linux 9. Asegúrate de ajustar los valores específicos, como la dirección IP estática, la puerta de enlace y los servidores DNS, según tu propia configuración de red.



sudo ovs-vsctl del-br br0



Parece que el puente de red br0 se ha creado correctamente, así como la configuración del esclavo del puente con la interfaz enp3s0f0. Sin embargo, parece que br0 está siendo tratado como un dispositivo no gestionado por NetworkManager.

Podemos intentar resolver esto marcando el puente como gestionado por NetworkManager. Puedes hacerlo modificando el archivo de configuración correspondiente en /etc/NetworkManager/conf.d/. Aquí hay algunos pasos que puedes seguir:

Editar el archivo de configuración de NetworkManager:
```bash

sudo nano /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
Agrega la línea para incluir br0 como dispositivo gestionado:
csharp

[keyfile]
unmanaged-devices=none
Guarda y cierra el archivo.
Una vez que hayas realizado estos cambios, reinicia NetworkManager:

```bash

sudo systemctl restart NetworkManager
Después de reiniciar NetworkManager, intenta nuevamente activar la conexión br0:

```bash

sudo nmcli connection up br0
Con suerte, esto debería permitir que NetworkManager gestione el puente de red br0 correctamente. Si sigues experimentando problemas, avísame para que pueda ayudarte más.


Detener y desactivar Open vSwitch:
```bash

sudo systemctl stop openvswitch
sudo systemctl disable openvswitch
Deshabilitar el inicio automático de Open vSwitch:
```bash

sudo systemctl mask openvswitch
Reiniciar NetworkManager:
```bash

sudo systemctl restart NetworkManager

Para solucionar este problema, necesitas configurar NetworkManager para que gestione la interfaz br0. Puedes hacerlo creando un archivo de configuración específico para br0 en /etc/NetworkManager/conf.d/. Aquí hay una forma de hacerlo:

Abre un editor de texto y crea un nuevo archivo de configuración para br0 en /etc/NetworkManager/conf.d/. Puedes nombrarlo como quieras, por ejemplo, br0.conf.

En este nuevo archivo de configuración, agrega la siguiente configuración:

csharp

[device]
match-device=br0
Esto le indica a NetworkManager que debe gestionar la interfaz br0.

Guarda el archivo y ciérralo.

Reinicia NetworkManager para que aplique los cambios:


sudo systemctl restart NetworkManager












Parece que el problema persiste y la interfaz br0 aún se considera no administrada. Probemos una solución alternativa:

Vamos a editar el archivo /etc/sysconfig/network-scripts/ifcfg-br0 para asegurarnos de que la interfaz esté marcada como administrada por NetworkManager.

Abre el archivo /etc/sysconfig/network-scripts/ifcfg-br0 en un editor de texto como nano o vi. Puedes usar el siguiente comando para abrirlo con nano:

```bash

sudo nano /etc/sysconfig/network-scripts/ifcfg-br0
Dentro del archivo, busca la línea que comienza con NM_CONTROLLED= y asegúrate de que esté configurada como yes, de esta manera:
plaintext

NM_CONTROLLED=yes
Guarda los cambios y cierra el editor de texto.

Luego, reinicia el servicio de NetworkManager para que los cambios surtan efecto:

```bash

sudo systemctl restart NetworkManager
Intenta activar la conexión br0 nuevamente con el siguiente comando:
```bash

sudo nmcli connection up br0
Esperemos que con estos pasos logremos corregir el problema y puedas activar la interfaz br0 sin problemas.



[victory@server ~]$ ip addr show br0
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.35/24 brd 192.168.0.255 scope global noprefixroute br0
       valid_lft forever preferred_lft forever
    inet6 fe80::2e76:8aff:feac:debc/64 scope link
       valid_lft forever preferred_lft forever
[victory@server ~]$ sudo nmcli connection up br0
[sudo] password for victory:
La conexión se ha activado correctamente (master waiting for slaves) (ruta activa D-Bus: /org/freedesktop/NetworkManager/ActiveConnection/7)
[victory@server ~]$ sudo brctl show
bridge name     bridge id               STP enabled     interfaces
br0             8000.2c768aacdebc       yes             enp3s0f0
[victory@server ~]$ sudo brctl addif br0 enp3s0f0
device enp3s0f0 is already a member of a bridge; can't add it to bridge br0.
[victory@server ~]$ sudo systemctl restart NetworkManager
[victory@server ~]$ sudo systemctl restart libvirtd




[victory@server ~]$ sudo nmcli con mod br0 ipv4.addresses "192.168.0.35/24"
[sudo] password for victory:
[victory@server ~]$ sudo nmcli con mod br0 ipv4.gateway "192.168.0.1"
[victory@server ~]$ sudo nmcli con mod br0 ipv4.dns "8.8.8.8,8.8.4.4"
[victory@server ~]$ sudo nmcli con mod br0 ipv4.method manual
[victory@server ~]$ sudo systemctl restart NetworkManager
[victory@server ~]$ sudo systemctl restart NetworkManager
[victory@server ~]$ ip addr show br0
10: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.16/24 brd 192.168.0.255 scope global dynamic noprefixroute br0
       valid_lft 85410sec preferred_lft 85410sec
    inet 192.168.0.35/24 brd 192.168.0.255 scope global secondary noprefixroute br0
       valid_lft forever preferred_lft forever
    inet6 fe80::7666:f262:9084:9f5f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
[victory@server ~]$ ip addr show br0
10: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 2c:76:8a:ac:de:bc brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.16/24 brd 192.168.0.255 scope global dynamic noprefixroute br0
       valid_lft 85309sec preferred_lft 85309sec
    inet 192.168.0.35/24 brd 192.168.0.255 scope global secondary noprefixroute br0
       valid_lft forever preferred_lft forever
    inet6 fe80::7666:f262:9084:9f5f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever