# Documentación para replicar la configuración de red y nftables

Este documento describe los pasos necesarios para configurar las rutas y reglas de firewall en los nodos master1, freeipa1, y bastion1 para asegurar conectividad entre las subredes y hacia Internet.

Nodo master1
1. Configuración de rutas
Ejecuta los siguientes comandos para agregar las rutas necesarias:

bash
Copy code
# Ruta para la subred 10.17.3.0/24 a través del gateway 10.17.4.1
sudo ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
2. Verificación
Prueba la conectividad:

bash
Copy code
# Conexión al nodo FreeIPA
ping -c 4 10.17.3.11

# Conexión a Bastion
ping -c 4 192.168.0.20
Nodo freeipa1
1. Configuración de rutas
Ejecuta los siguientes comandos para agregar las rutas necesarias:

bash
Copy code
# Ruta para la subred 10.17.4.0/24 a través del gateway 10.17.3.1
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0

# Ruta para la subred 192.168.0.0/24 a través del gateway 10.17.3.1
sudo ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
2. Verificación
Prueba la conectividad:

bash
Copy code
# Conexión a Bastion
ping -c 4 192.168.0.20

# Conexión al nodo Master
ping -c 4 10.17.4.21
Nodo bastion1
1. Configuración de rutas
Ejecuta los siguientes comandos para agregar las rutas necesarias:

bash
Copy code
# Ruta predeterminada para Internet
sudo ip route add default via 192.168.0.1 dev eth0

# Ruta para la subred 10.17.3.0/24 a través de la dirección 192.168.0.18
sudo ip route add 10.17.3.0/24 via 192.168.0.18 dev eth0

# Ruta para la subred 10.17.4.0/24 a través de la dirección 192.168.0.18
sudo ip route add 10.17.4.0/24 via 192.168.0.18 dev eth0
2. Configuración de nftables
Ejecuta los siguientes comandos para configurar las reglas de firewall con nftables:

bash
Copy code
# Limpiar configuraciones previas
sudo nft flush ruleset

# Crear tabla y cadenas básicas
sudo nft add table ip filter
sudo nft add chain ip filter INPUT { type filter hook input priority 0\; policy accept\; }
sudo nft add chain ip filter FORWARD { type filter hook forward priority 0\; policy accept\; }
sudo nft add chain ip filter OUTPUT { type filter hook output priority 0\; policy accept\; }

# Permitir tráfico entre subredes
sudo nft add rule ip filter FORWARD ip saddr 10.17.3.0/24 ip daddr 10.17.4.0/24 accept
sudo nft add rule ip filter FORWARD ip saddr 10.17.4.0/24 ip daddr 10.17.3.0/24 accept

# Configuración de NAT para salida a Internet
sudo nft add table ip nat
sudo nft add chain ip nat PREROUTING { type nat hook prerouting priority dstnat\; policy accept\; }
sudo nft add chain ip nat POSTROUTING { type nat hook postrouting priority srcnat\; policy accept\; }
sudo nft add rule ip nat POSTROUTING ip saddr 192.168.0.0/24 oifname "eth0" masquerade
sudo nft add rule ip nat POSTROUTING ip saddr 10.17.3.0/24 oifname "eth0" masquerade
sudo nft add rule ip nat POSTROUTING ip saddr 10.17.4.0/24 oifname "eth0" masquerade
3. Persistencia de configuración
Guardar configuraciones de rutas
Guarda las rutas en /etc/sysconfig/network-scripts/route-eth0:

bash
Copy code
default via 192.168.0.1 dev eth0
10.17.3.0/24 via 192.168.0.18 dev eth0
10.17.4.0/24 via 192.168.0.18 dev eth0
Guardar reglas de nftables
Guarda las reglas de nftables en /etc/sysconfig/nftables.conf:

bash
Copy code
table ip filter {
    chain INPUT {
        type filter hook input priority 0; policy accept;
    }

    chain FORWARD {
        type filter hook forward priority 0; policy accept;
        ip saddr 10.17.3.0/24 ip daddr 10.17.4.0/24 accept;
        ip saddr 10.17.4.0/24 ip daddr 10.17.3.0/24 accept;
    }

    chain OUTPUT {
        type filter hook output priority 0; policy accept;
    }
}

table ip nat {
    chain PREROUTING {
        type nat hook prerouting priority dstnat; policy accept;
    }

    chain POSTROUTING {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 192.168.0.0/24 oifname "eth0" masquerade;
        ip saddr 10.17.3.0/24 oifname "eth0" masquerade;
        ip saddr 10.17.4.0/24 oifname "eth0" masquerade;
    }
}
Aplica los cambios:

bash
Copy code
sudo systemctl restart network
sudo systemctl restart nftables
Verificación General
Prueba conectividad entre todos los nodos:

bash
Copy code
ping -c 4 <IP de cualquier nodo>
Prueba salida a Internet desde todos los nodos:

bash
Copy code
ping -c 4 8.8.8.8
Con esta documentación, puedes replicar la configuración en cualquier entorno similar.


__


5. Alternativa: Usar un archivo de configuración directamente
Si los errores persisten, puedes definir las reglas en un archivo y cargarlas directamente:

Crear el archivo de configuración:

bash
Copy code
sudo nano /etc/sysconfig/nftables.conf
Contenido del archivo:

text
Copy code
table ip nat {
    chain POSTROUTING {
        type nat hook postrouting priority srcnat; policy accept;
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" masquerade
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" masquerade
    }
}
Cargar las reglas:

bash
Copy code
sudo nft -f /etc/sysconfig/nftables.conf
Verificar reglas:

bash
Copy code
sudo nft list ruleset
