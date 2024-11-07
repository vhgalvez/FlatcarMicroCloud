
# Configuración del Host

## `/etc/sysconfig/network-scripts/ifcfg-br0`

```ini
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
NM_CONTROLLED=yes
DELAY=0
```

## `/etc/sysconfig/network-scripts/ifcfg-enp3s0f0`

```ini
DEVICE=enp3s0f0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
BRIDGE=br0
```

```bash
sudo systemctl restart NetworkManager
```

```bash
ip addr show br0
ip addr show enp3s0f0
```

# Revisión de la Máquina Virtual


## `/etc/sysconfig/network-scripts/ifcfg-eth0` 

```ini
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
BRIDGE=br0  
```

## `/etc/sysconfig/network-scripts/ifcfg-br0`


```ini
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
BOOTPROTO=static
IPADDR=192.168.0.35
PREFIX=24
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=8.8.4.4
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
```

```bash
sudo systemctl restart NetworkManager
```

```bash
ip addr show br0
ip addr show eth0
```

sudo nmcli connection down br0 && sudo nmcli connection up br0




Comprobar que NetworkManager Controla las Interfaces
NetworkManager debe estar configurado para gestionar las interfaces. Abre el archivo de configuración de NetworkManager:

```bash

sudo nano /etc/NetworkManager/NetworkManager.conf
```
Asegúrate de que contenga las siguientes líneas:

```ini

[main]
plugins=ifcfg-rh,keyfile

[ifcfg-rh]
managed=true
```

5. Eliminar Configuraciones DHCP Residuales
Para asegurarte de que no hay configuraciones DHCP que interfieran, puedes verificar y eliminar cualquier configuración residual de dhcp en /etc/sysconfig/network-scripts/.

bash

sudo grep -r 'dhcp' /etc/sysconfig/network-scripts/