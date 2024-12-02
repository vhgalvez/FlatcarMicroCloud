## Escenario
- Bastion1 tiene la IP 192.168.0.20 en la red LAN.
- Subred interna (NAT): 10.17.4.0/24 para máquinas virtuales.
- Cliente Windows 11 está en la misma red LAN (192.168.0.x).

**El objetivo es:**
- Configurar una VPN para que el cliente Windows acceda a las máquinas virtuales (NAT) y al servidor bastión.
- Mantener acceso a Internet y red LAN desde el cliente.

## Paso a Paso

### 1. Configurar el Servidor VPN (Bastion1)

#### 1.1. Actualizar el sistema e instalar WireGuard
Ejecuta en Bastion1 (AlmaLinux):

```bash
sudo dnf update -y
sudo dnf install -y epel-release
sudo dnf install -y wireguard-tools iptables
```

#### 1.2. Crear claves para WireGuard
Genera las claves necesarias:

```bash
cd /etc/wireguard
umask 077

# Claves del servidor
wg genkey | tee server_private.key | wg pubkey > server_public.key

# Claves del cliente
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Mostrar las claves para copiarlas
cat server_private.key
cat server_public.key
cat client_private.key
cat client_public.key
```

**Nota:** Copia las claves privadas y públicas en un lugar seguro.

#### 1.3. Configurar WireGuard en el servidor
Crea el archivo de configuración del servidor `/etc/wireguard/wg0.conf`:

```bash
sudo nano /etc/wireguard/wg0.conf
```

Pega lo siguiente (reemplaza las claves):

```ini
[Interface]
PrivateKey = <server_private.key>   # Clave privada del servidor
Address = 10.0.0.1/24              # Subred de la VPN
ListenPort = 51820

PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = <client_public.key>   # Clave pública del cliente
AllowedIPs = 10.0.0.2/32          # IP del cliente en la VPN
```
Guarda y cierra el archivo.

#### 1.4. Habilitar el reenvío de paquetes
Permitir el enrutamiento de paquetes:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

Hacerlo permanente:

```bash
sudo nano /etc/sysctl.conf
```

Agrega esta línea o verifica que esté presente:

```bash
net.ipv4.ip_forward=1
```

Luego:

```bash
sudo sysctl -p
```

#### 1.5. Configurar el firewall
Configura el firewall para permitir WireGuard:

```bash
sudo firewall-cmd --permanent --add-port=51820/udp
sudo firewall-cmd --permanent --add-masquerade
sudo firewall-cmd --reload
```

#### 1.6. Iniciar WireGuard
Levanta la VPN y habilítala para que se inicie al arrancar:

```bash
sudo wg-quick up wg0
sudo systemctl enable wg-quick@wg0
```

Verifica el estado:

```bash
sudo wg show
```

### 2. Configurar el Cliente (Windows 11)

#### 2.1. Instalar WireGuard
Descarga e instala el cliente oficial de WireGuard desde [wireguard.com](https://www.wireguard.com/).

#### 2.2. Configurar el cliente
- Abre la aplicación de WireGuard.
- Haz clic en "Add Tunnel" > "Add Empty Tunnel".
- Configura el túnel con el siguiente formato:

```ini
[Interface]
PrivateKey = <client_private.key>  # Clave privada del cliente
Address = 10.0.0.2/24             # IP del cliente en la VPN
DNS = 8.8.8.8                     # Servidor DNS (opcional)

[Peer]
PublicKey = <server_public.key>   # Clave pública del servidor
AllowedIPs = 10.0.0.0/24, 192.168.0.0/24  # Subredes de la VPN y LAN
Endpoint = 192.168.0.20:51820     # Dirección IP del servidor y puerto
PersistentKeepalive = 25
```

Guarda y activa el túnel.

### 3. Probar la Conexión

#### 3.1. Desde el cliente Windows
Verifica la conectividad con el servidor:

```cmd
ping 10.0.0.1
```

Prueba acceso a una máquina en la red NAT (por ejemplo, 10.17.4.21):

```cmd
ping 10.17.4.21
```

Prueba acceso a dispositivos en la red LAN (por ejemplo, 192.168.0.30):

```cmd
ping 192.168.0.30
```

#### 3.2. Desde el servidor
Verifica conexiones activas:

```bash
sudo wg show
```

### 4. Resolución de Problemas

#### 4.1. No hay conectividad con la VPN
Verifica el puerto abierto en el firewall:

```bash
sudo firewall-cmd --list-ports
```

Asegúrate de que el túnel está activo:

```bash
sudo wg show
```

#### 4.2. No hay acceso a la red NAT
Confirma que el servidor puede acceder a la red NAT:

```bash
ping 10.17.4.21
```

Asegúrate de que las reglas de iptables están configuradas correctamente:

```bash
sudo iptables -t nat -L -v
```

#### 4.3. Cliente pierde acceso a la red local o a Internet
Asegúrate de que `AllowedIPs` en el cliente esté configurado para incluir solo las subredes necesarias:

```ini
AllowedIPs = 10.0.0.0/24, 192.168.0.0/24
```

Con estos pasos, tendrás configurada una VPN funcional en tu red LAN con acceso a las máquinas virtuales y mantendrás acceso a Internet y la red local desde el cliente Windows.




sudo docker run --rm -it ghcr.io/wg-easy/wg-easy wgpw '123456'


# WireGuard
-A FORWARD -i wg0 -o enp4s0f0 -j ACCEPT
-A FORWARD -i enp4s0f0 -o wg0 -j ACCEPT
-A POSTROUTING -s 10.8.0.0/24 -o enp4s0f0 -j MASQUERADE


sudo setenforce 0
sudo systemctl restart libvirtd

sudo modprobe nft_nat
sudo modprobe nf_nat
sudo modprobe ip_tables



sudo modprobe iptable_nat
sudo modprobe nf_nat


sudo systemctl restart iptables
sudo systemctl status iptables


sudo modprobe iptable_nat
sudo modprobe nf_conntrack
sudo modprobe nf_conntrack_netlink
sudo modprobe nf_conntrack_ipv4

sudo systemctl restart iptables
sudo systemctl status iptables


windows:
route add 192.168.0.0 mask 255.255.255.0 10.8.0.1
route add 10.17.3.0 mask 255.255.255.0 10.8.0.1
route add 10.17.4.0 mask 255.255.255.0 10.8.0.1


sudo podman-compose up -d
sudo podman-compose down


route add 192.168.0.0 mask 255.255.255.0 10.8.0.1 metric 10

sudo ip route add default via 192.168.0.1 dev enp4s0f0

sudo ip route del default via 192.168.0.1 dev enp3s0f1
sudo ip route del default via 192.168.0.1 dev enp4s0f1
sudo ip route del default via 192.168.0.1 dev br0
