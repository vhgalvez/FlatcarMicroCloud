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



### VNC mobaxterm



```bash 
~/.vnc/xstartup
```

cat /etc/systemd/system/vncserver@:1.service

sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service
sudo systemctl status vncserver@:1.service

__

sudo systemctl status vncserver@:3.service
cat /usr/lib/systemd/system/vncserver@.service