

# 0. Configuración previa
sudo setenforce 0
sudo systemctl restart libvirtd
sudo systemctl restart NetworkManager

# 1. Limpiar reglas anteriores
sudo nft flush ruleset

# 2. Crear tabla y cadena de NAT
sudo nft add table ip nat
sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }

# 2.1 Agregar reglas de NAT para salida a Internet por enp4s0f0
sudo nft add rule ip nat postrouting ip saddr 10.17.5.0/24 oifname enp4s0f0 masquerade
sudo nft add rule ip nat postrouting ip saddr 10.17.4.0/24 oifname enp4s0f0 masquerade
sudo nft add rule ip nat postrouting ip saddr 10.17.3.0/24 oifname enp4s0f0 masquerade

# 3. Crear tabla y cadena de filtrado INPUT
sudo nft add table ip filter
sudo nft add chain ip filter INPUT { type filter hook input priority 0 \; policy accept \; }

# 4. Reglas para permitir tráfico necesario
sudo nft add rule ip filter INPUT udp dport 123 accept               # NTP
sudo nft add rule ip filter INPUT tcp dport 3389 accept              # XRDP
sudo nft add rule ip filter INPUT icmp type echo-request accept      # Ping

# 5. Guardar configuración para que persista tras reinicio
sudo nft list ruleset | sudo tee /etc/sysconfig/nftables.conf

# 6. Verificar reglas activas
sudo nft list ruleset


# SELINUX

sudo setenforce 0
sudo systemctl restart libvirtd

sudo sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config



## 4. Configuración de iptables

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


sudo iptables -A LIBVIRT_FWI -s 10.17.3.0/24 -d 10.17.4.0/24 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A LIBVIRT_FWO -s 10.17.4.0/24 -d 10.17.3.0/24 -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A LIBVIRT_FWO -s 10.17.5.0/24 -d 10.17.3.0/24 -p icmp --icmp-type echo-request -j ACCEPT









