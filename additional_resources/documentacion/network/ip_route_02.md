🔧 Comandos a ejecutar en cada VM según su subred
🧩 Para VMs en 10.17.3.0/24 (DNS/NTP/CoreDNS/Infra)
bash
Copiar
Editar
ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
ip route add default via 10.17.3.1 dev eth0
🧠 Para VMs en 10.17.4.0/24 (K3s Masters, Workers, Storage)
bash
Copiar
Editar
ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.4.1 dev eth0
ip route add default via 10.17.4.1 dev eth0
🚪 Para VMs en 10.17.5.0/24 (VIPs de API y Web)
bash
Copiar
Editar
ip route add 192.168.0.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.3.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.5.1 dev eth0
ip route add default via 10.17.5.1 dev eth0
🖧 Para VM 192.168.0.30 (Load Balancer o Gateway NAT entre redes)
Esta máquina debe tener reglas de reenvío activas para que funcione como puente entre redes:

bash
Copiar
Editar
# Habilitar reenvío de paquetes
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

# Opcional: NAT para acceso a internet si se desea que las VMs salgan a internet a través de esta máquina
iptables -t nat -A POSTROUTING -s 10.17.0.0/16 -o br0 -j MASQUERADE
✅ Recomendaciones Finales
Asegúrate de que los bridges NAT estén correctamente definidos en libvirt (nat_network_01, nat_network_02, nat_network_03) con gateway en .1 para cada subred.

Aplica estas rutas en cada VM con un script cloud-init, Ignition, o manualmente con runcmd.


_______________________


Las VMs de las redes privadas 10.17.3.0/24, 10.17.4.0/24 y 10.17.5.0/24 tengan comunicación entre sí,

y todas puedan acceder a la red 192.168.0.0/24 (física/puente br0) y a internet si es necesario.

✅ Objetivo: rutas necesarias para comunicación entre redes y con el host
Red	Rol Principal	Gateway sugerido
10.17.3.0/24	DNS, NTP, infra cloud-config	10.17.3.1 (libvirt NAT)
10.17.4.0/24	Clúster K3s (masters, workers, storage)	10.17.4.1
10.17.5.0/24	VIPs de API/Ingress (balanceadores)	10.17.5.1
192.168.0.0/24	Red física (host + bridge br0)	192.168.0.1 (router)

🔧 En el host (ProLiant, Rocky Linux)
Agrega las rutas para que el host conozca las subredes internas:

bash
Copiar
Editar
sudo ip route add 10.17.3.0/24 dev virbr_kube02
sudo ip route add 10.17.4.0/24 dev virbr_kube03
sudo ip route add 10.17.5.0/24 dev virbr_kube05
Estas rutas permitirán al host comunicarse con las VMs de esas redes.

🧠 En las VMs de cada red (como cloud-init o runcmd)
🌐 VMs en red 10.17.3.x (infra)
bash
Copiar
Editar
ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.3.1 dev eth0
ip route add default via 10.17.3.1 dev eth0
☸️ VMs en red 10.17.4.x (K3s masters/workers/storage)
bash
Copiar
Editar
ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0
ip route add 10.17.5.0/24 via 10.17.4.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.4.1 dev eth0
ip route add default via 10.17.4.1 dev eth0
🎯 VMs en red 10.17.5.x (VIPs / balanceadores)
bash
Copiar
Editar
ip route add 10.17.3.0/24 via 10.17.5.1 dev eth0
ip route add 10.17.4.0/24 via 10.17.5.1 dev eth0
ip route add 192.168.0.0/24 via 10.17.5.1 dev eth0
ip route add default via 10.17.5.1 dev eth0
🛡️ Opcional: en k8s-api-lb (192.168.0.30)
Si actúa como gateway, agrega NAT:

bash
Copiar
Editar
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

sudo iptables -t nat -A POSTROUTING -s 10.17.0.0/16 -o br0 -j MASQUERADE