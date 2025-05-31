# Configuración de Rutas IP

## 🔧 Comandos a ejecutar en cada VM según su subred

### 🧩 Para VMs en 10.17.3.0/24 (DNS/NTP/CoreDNS/Infra)

```bash
ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
ip route add default via 10.17.3.1 dev eth0
```

### 🧠 Para VMs en 10.17.4.0/24 (K3s Masters, Workers, Storage)

```bash
ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.4.1 dev eth0
ip route add default via 10.17.4.1 dev eth0
```

### 🚪 Para VMs en 10.17.5.0/24 (VIPs de API y Web)

```bash
ip route add 192.168.0.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.3.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.5.1 dev eth0
ip route add default via 10.17.5.1 dev eth0
```

## 🖧 Para VM 192.168.0.30 (Load Balancer o Gateway NAT entre redes)

Esta máquina debe tener reglas de reenvío activas para que funcione como puente entre redes:

```bash
# Habilitar reenvío de paquetes
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Opcional: NAT para acceso a internet si se desea que las VMs salgan a internet a través de esta máquina
iptables -t nat -A POSTROUTING -s 10.17.0.0/16 -o br0 -j MASQUERADE
```

## ✅ Recomendaciones Finales

Asegúrate de que los bridges NAT estén correctamente definidos en libvirt (nat_network_01, nat_network_02, nat_network_03) con gateway en `.1` para cada subred.

Aplica estas rutas en cada VM con un script cloud-init, Ignition, o manualmente con `runcmd`.




# Configuración de Rutas IP para Redes kvm baremetal 

## 🌐 Redes y VMs
---

## 🔧 En el host (ProLiant, Rocky Linux)

Agrega las rutas para que el host conozca las subredes internas:

```bash
sudo ip route add 10.17.3.0/24 dev virbr_kube02
sudo ip route add 10.17.4.0/24 dev virbr_kube03
sudo ip route add 10.17.5.0/24 dev virbr_kube05
```

Estas rutas permitirán al host comunicarse con las VMs de esas redes.

---

## 🧠 En las VMs de cada red (como cloud-init o runcmd)

### 🌐 VMs en red 10.17.3.x (infra)

```bash
ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
ip route add default via 10.17.3.1 dev eth0
```

### ☸️ VMs en red 10.17.4.x (K3s masters/workers/storage)

```bash
ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.4.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
ip route add default via 10.17.4.1 dev eth0
```

### 🎯 VMs en red 10.17.5.x (VIPs / balanceadores)

```bash
ip route add 10.17.3.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.5.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.5.1 dev eth0
ip route add default via 10.17.5.1 dev eth0
```

---

## 🛡️ Opcional: en k8s-api-lb (192.168.0.30)

Si actúa como gateway, agrega NAT:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

sudo iptables -t nat -A POSTROUTING -s 10.17.0.0/16 -o br0 -j MASQUERADE
```