### Reiniciar el servicio `libvirtd`

```bash
sudo systemctl restart libvirtd
```

Este comando reinicia el servicio libvirtd, que es responsable de la gestión de máquinas virtuales usando la biblioteca libvirt. Esto puede ser necesario si se han hecho cambios en la configuración o si el servicio no está funcionando correctamente.

Reiniciar el servicio `iptables`

```bash
sudo systemctl restart iptables
```

Este comando reinicia el servicio `iptables`, que es el sistema de filtrado de paquetes de Linux. Reiniciar este servicio aplicará cualquier cambio de configuración reciente en las reglas de cortafuegos.

Reiniciar el servicio `NetworkManager`

```bash
sudo systemctl restart NetworkManager
```

Este comando reinicia el servicio `NetworkManager`, que es responsable de gestionar todas las conexiones de red en el sistema. Reiniciarlo puede ayudar a resolver problemas de conectividad de red o aplicar cambios en la configuración de red.

```bash
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --reload
```

### Reiniciar

```bash

sudo setenforce 0
sudo systemctl restart libvirtd

sudo systemctl restart nftables
sudo systemctl restart NetworkManager
```

sudo systemctl restart libvirtd (deprecrado)

# SELinux

```bash
sudo setenforce 0
sudo systemctl restart NetworkManager
sudo systemctl restart nftables
sudo systemctl restart virtqemud.service

```

sudo systemctl status virtqemud.service

# 🔓 1. (Opcional) Desactiva SELinux temporalmente si estás depurando

sudo setenforce 0

# 🌐 2. Reinicia servicios de red (útil para bridges virtuales o DNS)

sudo systemctl restart NetworkManager

# 🔥 3. Reinicia reglas de firewall (como nftables o firewalld)

sudo systemctl restart nftables # O reemplaza por firewalld si usas firewalld

# sudo systemctl restart firewalld

# 🧠 4. Reinicia todos los servicios relacionados con libvirt y QEMU

sudo systemctl restart virtqemud.service # QEMU daemon
sudo systemctl restart virtlogd.service # Logging de libvirt/QEMU
sudo systemctl restart virtproxyd.service # Proxy de libvirt
sudo systemctl restart virtnetworkd.service # Redes de libvirt (NAT/bridge)
sudo systemctl restart virtstoraged.service # Almacenamiento libvirt

# ✅ Alternativa más rápida: reiniciar todos juntos

sudo systemctl restart virtqemud virtlogd virtproxyd virtnetworkd virtstoraged

sudo systemctl restart virtqemud virtlogd virtproxyd virtnetworkd virtstoraged nftables NetworkManager

ping -c 4 192.168.0.50; ping -c 4 10.17.4.21; ping -c 4 10.17.3.11; ping -c 4 192.168.0.1; ping -c 4 10.17.3.1; ping -c 4 8.8.8.8; ping -c 4 192.168.0.55

ping -c 4 10.17.5.20; ping -c 4 10.17.4.21; ping -c 4 10.17.3.11; ping -c 4 10.17.5.1; ping -c 4 10.17.3.1; ping -c 4 8.8.8.8; ping -c 4 10.17.5.10



sudo systemctl status virtqemud.service

systemctl status virtqemud virtlogd virtproxyd virtnetworkd virtstoraged
sudo systemctl is-enabled virtqemud.service

sudo nft add chain ip filter LIBVIRT_INP { type filter hook input priority filter \; }
sudo nft add rule ip filter LIBVIRT_INP iifname "virbr3" tcp dport 67 accept

sudo nft list ruleset | sudo tee /etc/sysconfig/nftables.conf

sudo systemctl restart virtqemud.service

sudo terraform apply --auto-approve --var-file=./terraform.tfvars

rpm -q iptables-nft

sudo update-alternatives --display iptables
sudo update-alternatives --config iptables

sudo update-alternatives --config iptables

### VNC mobaxterm

```bash
~/.vnc/xstartup
```

```bash

cat /etc/systemd/system/vncserver@:1.service

sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service
sudo systemctl status vncserver@:1.service
```

```bash
sudo systemctl status vncserver@:3.service
cat /usr/lib/systemd/system/vncserver@.service
```

sudo ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64

sudo nano /etc/libvirt/libvirtd.conf

firewall_backend = "nftables"
max_clients = 10
max_requests = 100

ls -l /etc/libvirt/virtqemud\*

Asegurar forwarding de ICMP
Revisa esto en tu sistema host (muy importante):

bash
Copiar
Editar
sudo sysctl net.ipv4.ip_forward
Debe devolver:

ini
Copiar
Editar
net.ipv4.ip_forward = 1
Si es 0, habilítalo así:

bash
Copiar
Editar
sudo sysctl -w net.ipv4.ip_forward=1
Y para hacerlo permanente:

bash
Copiar
Editar
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

sudo dnf install -y jq


sudo ip route add 10.17.5.0/24 via 10.17.4.1 dev eth0



## ✅ 🔧 Configuración de rutas necesarias para el balanceo y acceso en Kubernetes

### 🟢 Máquinas donde debes configurar rutas manualmente
- `load_balancer1` (IP: 10.17.3.12)
- `load_balancer2` (IP: 10.17.3.13)

Estas máquinas están en la red `10.17.3.0/24`, por lo tanto **requieren rutas hacia**:

- La red de **nodos master/worker**: `10.17.4.0/24`
- La red de **pods Flannel CNI**: `10.42.0.0/16`
- La red del **VIP del API server**: `10.17.5.0/24`

#### 🛠 Comandos a ejecutar (en ambas máquinas):
```bash
# 1. Ruta hacia red de nodos master/worker
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0

# 2. Ruta hacia red de pods (red flannel CNI)
sudo ip route add 10.42.0.0/16 via 10.17.3.1 dev eth0

# 3. Ruta hacia la red del VIP del API server (k8s-api-lb)
sudo ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
