

```bash
sudo setenforce 0
sudo systemctl restart libvirtd
sudo systemctl restart NetworkManager
```

Antes de agregar nuevas reglas, eliminamos todas las configuraciones previas:

```bash
sudo nft flush ruleset
```


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

Si después de reiniciar `physical1`, las reglas siguen activas y los nodos `master1` y `worker1` pueden salir a Internet, la configuración está completa. 🚀


# 10.17.4.21
sudo iptables -I FORWARD -i virbr1 -o virbr0 -j ACCEPT
sudo iptables -I FORWARD -i virbr0 -o virbr1 -j ACCEPT

# 10.17.5.10
sudo iptables -I FORWARD -i virbr1 -o virbr2 -j ACCEPT
sudo iptables -I FORWARD -i virbr2 -o virbr1 -j ACCEPT

# 10.17.5.10
sudo iptables -I FORWARD -i virbr2 -o virbr0 -j ACCEPT
sudo iptables -I FORWARD -i virbr0 -o virbr2 -j ACCEPT

# tiempo real puerto 123
sudo iptables -A INPUT -p udp --dport 123 -j ACCEPT

#  escritorio remoto xrdp puerto 3389
sudo iptables -I INPUT -p tcp --dport 3389 -j ACCEPT



### Agregar reglas de firewall en `physical1` para permitir el tráfico ICMP si es necesario:

```bash
sudo iptables -A LIBVIRT_FWI -s 10.17.3.0/24 -d 10.17.4.0/24 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A LIBVIRT_FWO -s 10.17.4.0/24 -d 10.17.3.0/24 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A LIBVIRT_FWO -s 10.17.5.0/24 -d 10.17.3.0/24 -p icmp --icmp-type echo-request -j ACCEPT

```
