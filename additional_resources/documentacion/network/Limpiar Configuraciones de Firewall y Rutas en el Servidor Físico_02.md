# Configuración de NAT con nftables en physical1

## 1. Diagnóstico Inicial

### Verificación de conectividad y reglas activas:

   ```bash
   ip route show
   ```

1. Verificar si el reenvío de paquetes está activado:
   
```bash
sudo sysctl -p
```

Salida esperada:

```bash
net.ipv4.ip_forward = 1
```
2. Revisar si hay reglas activas en nftables:
   
```bash
sudo nft list ruleset
```
Si está vacío, significa que no hay reglas configuradas.

3. En `master1`, verificar conectividad a Internet:
   
```bash
ping -c 4 8.8.8.8
```

Si hay pérdida del 100% de los paquetes, hay un problema de enrutamiento.


4. Realizar un `traceroute` para ver en dónde se está perdiendo el tráfico:
   

```bash
traceroute 8.8.8.8
```
   
Si el tráfico se queda atascado en `10.17.4.1`, significa que no está haciendo NAT correctamente.

## 2. Eliminación de reglas antiguas en nftables

Antes de agregar nuevas reglas, eliminamos todas las configuraciones previas:

```bash
sudo nft flush ruleset
```

Esto garantiza que no haya conflictos con reglas anteriores.

## 3. Configuración de NAT con nftables

### Agregar reglas de NAT en `physical1`

```bash
sudo nft add table ip nat
sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
sudo nft add rule ip nat postrouting ip saddr 10.17.5.0/24 oifname enp4s0f0 masquerade
sudo nft add rule ip nat postrouting ip saddr 10.17.4.0/24 oifname enp4s0f0 masquerade
sudo nft add rule ip nat postrouting ip saddr 10.17.3.0/24 oifname enp4s0f0 masquerade
```

Verificamos que las reglas fueron aplicadas correctamente:

```bash
sudo nft list ruleset
```

Salida esperada:

```bash
table ip nat {
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.17.5.0/24 oifname "enp4s0f0" masquerade
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" masquerade
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" masquerade
    }
}
```

### Verificamos que el tráfico de red se está enrutando correctamente:

```bash
sudo tcpdump -i enp4s0f0 icmp
```

### Agregar reglas de firewall en `physical1` para permitir el tráfico ICMP si es necesario:

```bash
sudo iptables -A LIBVIRT_FWI -s 10.17.3.0/24 -d 10.17.4.0/24 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A LIBVIRT_FWO -s 10.17.4.0/24 -d 10.17.3.0/24 -p icmp --icmp-type echo-request -j ACCEPT
```




## 4. Pruebas de conectividad

### Verificar conectividad desde `master1`

```bash
ping -c 4 8.8.8.8
```

Si ya responde, el problema está resuelto.

Si sigue sin funcionar, verificar si los paquetes están saliendo correctamente:

```bash
sudo tcpdump -i enp4s0f0 icmp
```

Si vemos tráfico saliendo hacia `8.8.8.8`, significa que el problema está en el ISP o en la configuración del gateway.

## 5. Hacer persistentes las reglas de nftables

Para evitar que las reglas se pierdan tras un reinicio:

```bash
sudo nft list ruleset | sudo tee /etc/sysconfig/nftables.conf
sudo systemctl enable nftables --now
```

## 6. Verificación final

Ejecutar los siguientes comandos para confirmar que la configuración es persistente:

```bash
sudo systemctl restart nftables
sudo systemctl status nftables
sudo nft list ruleset
```

Si después de reiniciar `physical1`, las reglas siguen activas y los nodos `master1` y `worker1` pueden salir a Internet, la configuración está completa. 🚀



10.17.4.21
sudo iptables -I FORWARD -i virbr1 -o virbr0 -j ACCEPT
sudo iptables -I FORWARD -i virbr0 -o virbr1 -j ACCEPT


10.17.5.10
sudo iptables -I FORWARD -i virbr1 -o virbr2 -j ACCEPT
sudo iptables -I FORWARD -i virbr2 -o virbr1 -j ACCEPT
