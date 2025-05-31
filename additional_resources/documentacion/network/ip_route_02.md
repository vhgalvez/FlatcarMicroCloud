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