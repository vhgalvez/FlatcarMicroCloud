# Para agregar las rutas de manera persistente en Linux, debes editar el archivo de configuración de la red correspondiente. En sistemas basados en Red Hat (como Rocky Linux) y Flatcar Linux, esto puede involucrar la edición de archivos en /etc/sysconfig/network-scripts/ o usando NetworkManager. A continuación, se proporcionan los pasos y los comandos para agregar estas rutas.

1. Agregar rutas en freeipa1:

Comandos para agregar rutas temporalmente:

```bash
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
sudo ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
```

Para hacer las rutas persistentes:

Edita o crea el archivo de configuración de la interfaz de red en /etc/sysconfig/network-scripts/route-eth0:

```bash
sudo nano /etc/sysconfig/network-scripts/route-eth0
```

Agrega las siguientes líneas:

```plaintext
10.17.4.0/24 via 10.17.3.1 dev eth0
192.168.0.0/24 via 10.17.3.1 dev eth0
```
Guarda el archivo y reinicia la red:

```bash

sudo systemctl restart network
1. Agregar rutas en bootstrap1:
Comandos para agregar rutas temporalmente:

```bash
sudo ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
sudo ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
```


```bash
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
sudo ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
```


Para hacer las rutas persistentes:

Edita o crea el archivo de configuración de la interfaz de red en /etc/sysconfig/network-scripts/route-eth0:

```bash
sudo nano /etc/sysconfig/network-scripts/route-eth0
```
Agrega las siguientes líneas:

```plaintext
10.17.3.0/24 via 10.17.4.1 dev eth0
192.168.0.0/24 via 10.17.4.1 dev eth0
```
Guarda el archivo y reinicia la red:

```bash
sudo systemctl restart network
```
# Verificación

Después de reiniciar la red en ambos nodos, verifica las rutas nuevamente con:

```bash
ip route
```

Estas configuraciones aseguran que las rutas se mantendrán a través de reinicios del sistema.

# Elimina rutas incorrectas
sudo ip route del 10.17.3.0/24 via 192.168.0.20 dev eth0
sudo ip route del 10.17.4.0/24 via 192.168.0.20 dev eth0

# Agrega rutas correctas
sudo ip route add 10.17.3.0/24 via 192.168.0.1 dev eth0
sudo ip route add 10.17.4.0/24 via 192.168.0.1 dev eth0

# Verifica conectividad
traceroute 10.17.4.20
traceroute 10.17.3.13

# Edita archivo de rutas persistentes
echo "10.17.3.0/24 via 192.168.0.1 dev eth0" | sudo tee -a /etc/sysconfig/network-scripts/route-eth0
echo "10.17.4.0/24 via 192.168.0.1 dev eth0" | sudo tee -a /etc/sysconfig/network-scripts/route-eth0

# Reinicia la red para aplicar cambios
sudo systemctl restart network



# Agrega rutas en servidor hp


sudo ip route add 10.17.3.0/24 dev virbr0
sudo ip route add 10.17.4.0/24 dev virbr1




```bash
sudo ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
sudo ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
```


```bash
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
sudo ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
```

```bash
sudo ip route del 10.17.3.0/24 via 192.168.0.20 dev eth0
sudo ip route del 10.17.4.0/24 via 192.168.0.20 dev eth0
```

