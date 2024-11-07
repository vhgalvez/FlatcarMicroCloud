
# Configuración Manual de Rutas para Redes NAT y Bridge

Para configurar manualmente las rutas de red en las máquinas virtuales bastion1, bootstrap1, y freeipa1, siga las siguientes instrucciones. Estas rutas permitirán la correcta comunicación entre las distintas redes NAT y la red bridge.

Resumen de Configuración de Rutas

Para bastion1:

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.42
sudo ip route add 10.17.4.0/24 via 192.168.0.42
```

Para bootstrap1:

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
sudo ip route add 10.17.3.0/24 via 10.17.4.1
```

Para freeipa1:

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
sudo ip route add 10.17.4.0/24 via 10.17.3.1
```

Configuración de las Rutas en bastion1

Añadir ruta para kube_network_02 (10.17.3.0/24)

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.42
```

Añadir ruta para kube_network_03 (10.17.4.0/24)

```bash
sudo ip route add 10.17.4.0/24 via 192.168.0.42
```

Configuración de las Rutas en bootstrap1

Añadir ruta para br0 (192.168.0.0/24)

```bash
sudo ip route add 192.168.0.0/24 via 10.17.4.1
```

Añadir ruta para kube_network_02 (10.17.3.0/24)

```bash
sudo ip route add 10.17.3.0/24 via 10.17.4.1
```

Configuración de las Rutas en freeipa1

Añadir ruta para br0 (192.168.0.0/24)

```bash
sudo ip route add 192.168.0.0/24 via 10.17.3.1
```

Añadir ruta para kube_network_03 (10.17.4.0/24)

```bash
sudo ip route add 10.17.4.0/24 via 10.17.3.1
```

Verificación de la Configuración de Rutas
Después de configurar las rutas, puede verificar que se hayan añadido correctamente utilizando el siguiente comando en cada máquina virtual:

```bash
sudo ip route
```

La salida debe mostrar las rutas configuradas según lo especificado. Por ejemplo, en bastion1, debería ver algo similar a:

```plaintext
default via 192.168.0.1 dev eth0 proto static metric 100
10.17.3.0/24 via 192.168.0.42 dev eth0
10.17.4.0/24 via 192.168.0.42 dev eth0
192.168.0.0/24 dev eth0 proto kernel scope link src 192.168.0.20 metric 100
```

# Conclusión

Estas configuraciones manuales de rutas permiten que las máquinas virtuales en las diferentes redes (bridge y NAT) se comuniquen correctamente entre sí. Esta configuración es esencial para asegurar una correcta conectividad en el entorno cefaslocalserver.com.

# En bastion1

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.42
sudo ip route add 10.17.4.0/24 via 192.168.0.42
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


# Verificar que las reglas se hayan guardado correctamente
sudo cat /etc/sysconfig/iptables

# Reiniciar el servicio de iptables
sudo systemctl restart iptables

# Verificar las reglas aplicadas
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v

# Habilitar el servicio de iptables

```bash
sudo systemctl enable iptables
sudo systemctl restart iptables
sudo systemctl status iptables
```




ping -c 4 192.168.0.20
ping -c 4 10.17.4.20
ping -c 4 10.17.3.11
ping -c 4 10.17.4.1
ping -c 4 10.17.3.1
ping -c 4 8.8.8.8
sudo ip route
hostnamectl
ip a