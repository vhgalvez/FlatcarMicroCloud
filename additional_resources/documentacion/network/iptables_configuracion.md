# Configuración de NAT y Reenvío de Tráfico en Rocky Linux 9
=============================================================

Este documento detalla los pasos para configurar NAT y reenvío de tráfico en Rocky Linux 9. La configuración permite que las máquinas virtuales en las redes 10.17.3.0/24 y 10.17.4.0/24 accedan a Internet a través de la interfaz enp4s0f0.

1. Configuración de Reenvío de IP
Primero, asegúrate de que el reenvío de IP esté habilitado en el servidor:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Para que esta configuración sea permanente, agrega o modifica la línea correspondiente en /etc/sysctl.conf:

```bash
sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
```

Luego, recarga la configuración de sysctl para aplicar los cambios:

```bash
sudo sysctl -p
```

2. Configuración de iptables

   
Edita el archivo de configuración de iptables en /etc/sysconfig/iptables y agrega las siguientes reglas:

```bash
sudo tee /etc/sysconfig/iptables <<EOF
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Permitir tráfico ICMP (ping)
-A INPUT -p icmp -j ACCEPT
-A FORWARD -p icmp -j ACCEPT

# Permitir tráfico SSH
-A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir tráfico HTTP y HTTPS
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

# Permitir tráfico DNS
-A INPUT -p udp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 53 -j ACCEPT

# Permitir tráfico entre br0 y las subredes
-A FORWARD -i br0 -o virbr0 -j ACCEPT
-A FORWARD -i br0 -o virbr1 -j ACCEPT
-A FORWARD -i virbr0 -o br0 -j ACCEPT
-A FORWARD -i virbr1 -o br0 -j ACCEPT

# Permitir tráfico entre las subredes 10.17.3.0/24 y 10.17.4.0/24
-A FORWARD -s 10.17.3.0/24 -d 10.17.4.0/24 -j ACCEPT
-A FORWARD -s 10.17.4.0/24 -d 10.17.3.0/24 -j ACCEPT

# Permitir tráfico entre la red 192.168.0.0/24 y las subredes
-A FORWARD -s 192.168.0.0/24 -d 10.17.3.0/24 -j ACCEPT
-A FORWARD -s 192.168.0.0/24 -d 10.17.4.0/24 -j ACCEPT
-A FORWARD -s 10.17.3.0/24 -d 192.168.0.0/24 -j ACCEPT
-A FORWARD -s 10.17.4.0/24 -d 192.168.0.0/24 -j ACCEPT

# Permitir todo el tráfico entrante y saliente en la interfaz br0
-A INPUT -i br0 -j ACCEPT
-A OUTPUT -o br0 -j ACCEPT

COMMIT

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# Configurar NAT para la red kube_network_02
-A POSTROUTING -s 10.17.3.0/24 -o br0 -j MASQUERADE

# Configurar NAT para la red kube_network_03
-A POSTROUTING -s 10.17.4.0/24 -o br0 -j MASQUERADE

# Configurar NAT para la red local a Internet
-A POSTROUTING -s 192.168.0.0/24 -o enp4s0f0 -j MASQUERADE
-A POSTROUTING -s 10.17.3.0/24 -o enp4s0f0 -j MASQUERADE
-A POSTROUTING -s 10.17.4.0/24 -o enp4s0f0 -j MASQUERADE

COMMIT
EOF
```

Reinicia el servicio iptables para aplicar las nuevas reglas:

```bash
sudo systemctl restart iptables
```

3. Configuración de Rutas IP
4. 
Agrega las rutas necesarias en cada máquina virtual para garantizar la conectividad entre las subredes.

# Bastion1

# Agrega la ruta por defecto

```bash
sudo ip route add default via 192.168.0.1 dev eth0 proto static metric 100
```

# Agrega las rutas para las subredes 10.17.3.0/24 y 10.17.4.0/24 a través del gateway 192.168.0.21

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.21 dev eth0
sudo ip route add 10.17.4.0/24 via 192.168.0.21 dev eth0
```


# Asegura la ruta de la subred 192.168.0.0/24

sudo ip route add 192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.20 metric 100

Verifica la configuración de rutas:

```bash
ip route
```

Salida esperada:

```plaintext
default via 192.168.0.1 dev eth0 proto static metric 100
10.17.3.0/24 via 192.168.0.21 dev eth0
10.17.4.0/24 via 192.168.0.21 dev eth0
192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.20 metric 100
```

# Bootstrap1


# Agrega la ruta por defecto

```bash
sudo ip route add default via 10.17.4.1 dev eth0
```


# Agrega la ruta por defecto con DHCP

    
```bash
sudo ip route add default via 10.17.4.1 dev eth0 proto dhcp src 10.17.4.20 metric 1024
```

# Asegura la ruta de la subred 10.17.4.0/24

    
```bash
sudo ip route add 10.17.4.0/24 dev eth0 proto kernel scope link src 10.17.4.20 metric 1024
```

# Asegura la ruta hacia la puerta de enlace de la subred 10.17.4.0/24

```bash
sudo ip route add 10.17.4.1 dev eth0 proto dhcp scope link src 10.17.4.20 metric 1024
```

Verifica la configuración de rutas:

```bash
ip route
```
Salida esperada:

```plaintext
default via 10.17.4.1 dev eth0
default via 10.17.4.1 dev eth0 proto dhcp src 10.17.4.20 metric 1024
10.17.4.0/24 dev eth0 proto kernel scope link src 10.17.4.20 metric 1024
10.17.4.1 dev eth0 proto dhcp scope link src 10.17.4.20 metric 1024
```

# FreeIPA1


# Agrega la ruta por defecto

```bash
sudo ip route add default via 10.17.3.1 dev eth0
```


# Agrega la ruta por defecto con DHCP

```bash
sudo ip route add default via 10.17.3.1 dev eth0 proto dhcp src 10.17.3.11 metric 100
```

# Asegura la ruta de la subred 10.17.3.0/24
    
    
```bash
sudo ip route add 10.17.3.0/24 dev eth0 proto kernel scope link src 10.17.3.11 metric 100
```
Verifica la configuración de rutas:

```bash
ip route
```

Salida esperada:

```plaintext
default via 10.17.3.1 dev eth0
default via 10.17.3.1 dev eth0 proto dhcp src 10.17.3.11 metric 100
10.17.3.0/24 dev eth0 proto kernel scope link src 10.17.3.11 metric 100
```

4. Verificación de la Configuración de Red

Verifica la configuración de red en la máquina virtual freeipa1 para asegurarte de que esté utilizando la puerta de enlace correcta y que pueda alcanzar la puerta de enlace:

```bash
nmcli dev show eth0
ip route
ip a
```

Ejemplo de salida esperada:

```plaintext
GENERAL.DEVICE:                         eth0
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         52:54:00:CA:07:3D
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     System eth0
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/2
IP4.ADDRESS[1]:                         10.17.3.11/24
IP4.GATEWAY:                            10.17.3.1
IP4.ROUTE[1]:                           dst = 0.0.0.0/0, nh = 10.17.3.1, mt = 100
IP4.DNS[1]:                             10.17.3.1
```

5. Comprobación de Conectividad
   

Ejecuta un script para verificar la conectividad desde freeipa1 y otras máquinas:

```bash
sudo ./check_connectivity.sh
```

Ejemplo de salida esperada:

```plaintext
IP Address              Status
----------              ------
192.168.0.20            Success
10.17.4.20              Success
10.17.3.11              Success
10.17.4.1               Success
10.17.3.1               Success
8.8.8.8                 Success

Conectividad Exitosa
```

1. Probar Conectividad a Internet

Intenta hacer ping a una dirección IP externa y a un dominio para verificar que la conectividad a Internet esté funcionando:

```bash
ping -c 4 8.8.8.8
ping -c 4 google.com
dig google.com
```


Con estos pasos documentados, podrás configurar y verificar NAT y reenvío de tráfico en un entorno de Rocky Linux 9, asegurando que las máquinas virtuales tengan acceso a Internet y puedan comunicarse entre sí a través de diferentes subredes.


