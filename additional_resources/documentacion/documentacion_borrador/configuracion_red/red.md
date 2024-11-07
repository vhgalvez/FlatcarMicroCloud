
# Configuración de iptables en el Servidor

1. Edición del Servicio iptables
Verificar el estado del servicio iptables:

```bash
sudo systemctl status iptables
```

Editar el archivo de configuración del servicio iptables:

```bash
sudo nano /usr/lib/systemd/system/iptables.service
```

Asegúrate de que el contenido sea el siguiente:

```plaintext
[Unit]
Description=IPv4 firewall with iptables
AssertPathExists=/etc/sysconfig/iptables
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/libexec/iptables/iptables.init start
ExecReload=/usr/libexec/iptables/iptables.init reload
ExecStop=/usr/libexec/iptables/iptables.init stop
Environment=BOOTUP=serial
Environment=CONSOLETYPE=serial

[Install]
WantedBy=multi-user.target

```

Reiniciar el servicio iptables:

```bash
sudo systemctl restart iptables
```

2. Configuración de Reglas de iptables
Editar el archivo de configuración de iptables:

```bash
sudo nano /etc/sysconfig/iptables
```

Añade o modifica las reglas como sigue:

plaintext

*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

# Enmascaramiento para las redes NAT

```bash
-A POSTROUTING -s 10.17.3.0/24 -o enp3s0f1 -j MASQUERADE
-A POSTROUTING -s 10.17.4.0/24 -o enp3s0f1 -j MASQUERADE


COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

# Permitir tráfico hacia y desde las redes NAT
-A FORWARD -i enp3s0f1 -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i enp3s0f1 -o virbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i virbr0 -o enp3s0f1 -j ACCEPT
-A FORWARD -i virbr1 -o enp3s0f1 -j ACCEPT

# Permitir tráfico entre las redes NAT
-A FORWARD -i virbr0 -o virbr1 -j ACCEPT
-A FORWARD -i virbr1 -o virbr0 -j ACCEPT

COMMIT
```


Aplicar las nuevas reglas:


```bash
sudo systemctl restart iptables
```

Habilitación del Reenvío de IP

1. Habilitar Temporalmente el Reenvío de IP

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

1. Habilitar Permanentemente el Reenvío de IP
Editar el archivo de configuración sysctl:

```bash
sudo nano /etc/sysctl.conf
```

Asegúrate de que la siguiente línea esté presente:

plaintext

net.ipv4.ip_forward = 1
Aplicar la configuración:

```bash
sudo sysctl -p
```

Configuración de Rutas en los Servidores

1. En el Servidor bastion1
Verificar las rutas actuales:

```bash
ip route
```
Agregar rutas para las redes 10.17.3.0/24 y 10.17.4.0/24 vía 192.168.0.42:

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
```

2. En los demás Servidores (bootstrap1, freeipa1)

Verificar las rutas actuales:

```bash
ip route
```
Agregar rutas si es necesario:

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
```

Verificación de la Conectividad

1. Verificar Conectividad con Pings
   
- Desde bastion1:

```bash
ping -c 2 192.168.0.20
ping -c 2 10.17.4.20
ping -c 2 10.17.3.11
ping -c 2 10.17.4.1
ping -c 2 10.17.3.1
ping -c 2 8.8.8.8
```

- Desde bootstrap1:

```bash
ping -c 2 192.168.0.20
ping -c 2 10.17.4.20
ping -c 2 10.17.3.11
ping -c 2 10.17.4.1
ping -c 2 10.17.3.1
ping -c 2 8.8.8.8
```
- Desde freeipa1:

```bash
ping -c 2 192.168.0.20
ping -c 2 10.17.4.20
ping -c 2 10.17.3.11
ping -c 2 10.17.4.1
ping -c 2 10.17.3.1
ping -c 2 8.8.8.8
```

1. Verificar la Configuración de Red y Rutas
Verificar direcciones IP:

```bash
ip addr
Verificar las rutas:
```

```bash
sudo ip route
```
Verificar la información del sistema:

```bash
hostnamectl
```

# Conclusión

Siguiendo estos pasos, hemos configurado con éxito el enrutamiento y las reglas de firewall para permitir la conectividad adecuada entre las diferentes redes en el entorno cefaslocalserver.com. Esta documentación proporciona una guía detallada para replicar esta configuración en otros entornos similares.