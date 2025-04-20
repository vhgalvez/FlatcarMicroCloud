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



sudo setenforce 0
sudo systemctl restart NetworkManager
sudo systemctl restart nftables
sudo systemctl restart virtproxyd.service
sudo systemctl restart virtnetworkd.service
sudo systemctl restart virtqemud.service


sudo systemctl restart virtqemud.service
sudo systemctl restart virtlogd.service
sudo systemctl restart virtproxyd.service
sudo systemctl restart virtnetworkd.service
sudo systemctl restart virtstoraged.service
sudo systemctl restart virtqemud virtlogd virtproxyd virtnetworkd virtstoraged

systemctl status virtqemud virtlogd virtproxyd virtnetworkd virtstoraged
sudo systemctl is-enabled virtqemud.service
sudo systemctl restart virtqemud.service


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


 ls -l /etc/libvirt/virtqemud*




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