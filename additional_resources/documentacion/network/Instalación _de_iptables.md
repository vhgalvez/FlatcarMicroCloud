
## Instalación de iptables

Actualizar la lista de paquetes:

```bash
sudo dnf update -y
```

Instalar iptables:

```bash
sudo dnf install iptables iptables-services -y
```

Configuración del Servicio iptables
Crear el archivo de servicio para iptables:

```bash
sudo nano /usr/lib/systemd/system/iptables.service
```

Agregar el siguiente contenido al archivo de servicio:

```ini
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

Guardar y cerrar el archivo.

Creación del Archivo de Configuración de iptables
Crear el archivo de configuración iptables:

```bash
sudo nano /etc/sysconfig/iptables
```

Agregar las reglas necesarias al archivo de configuración:

```plaintext
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

```

Guardar y cerrar el archivo.

Habilitar y Arrancar el Servicio iptables

Recargar los archivos de configuración del sistema:

```bash
sudo systemctl daemon-reload
```

Habilitar el servicio iptables para que se inicie al arranque:

```bash
sudo systemctl enable iptables
```

Iniciar el servicio iptables:

```bash
sudo systemctl start iptables
```

Verificación del Estado del Servicio iptables

Verificar el estado del servicio iptables:

```bash
sudo systemctl status iptables
```

La salida debería mostrar que el servicio iptables está activo (exited) y se inició correctamente.


```bash

● iptables.service - IPv4 firewall with iptables
     Loaded: loaded (/usr/lib/systemd/system/iptables.service; enabled; preset: disabled)
     Active: active (exited) since Wed 2024-05-22 23:01:38 CEST; 38min ago
    Process: 71989 ExecStart=/usr/libexec/iptables/iptables.init start (code=exited, status=0/SUCCESS)
   Main PID: 71989 (code=exited, status=0/SUCCESS)
        CPU: 27ms

may 22 23:01:38 server.cefas.com systemd[1]: Starting IPv4 firewall with iptables...
may 22 23:01:38 server.cefas.com iptables.init[71989]: iptables: Applying firewall rules: [  OK  ]
may 22 23:01:38 server.cefas.com systemd[1]: Finished IPv4 firewall with iptables.
```

Con estos pasos, has instalado y configurado correctamente el servicio iptables en tu sistema Rocky Linux 9.x. Ahora puedes administrar tus reglas de firewall de manera eficiente.

```bash
sudo service iptables save
```

```bash
sudo service iptables restart
```

```bash
sudo service iptables status
```
