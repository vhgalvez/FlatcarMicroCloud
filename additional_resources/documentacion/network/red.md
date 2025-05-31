# Reiniciar el servicio `libvirtd`

```bash
sudo systemctl restart libvirtd
```

Este comando reinicia el servicio libvirtd, que es responsable de la gestión de máquinas virtuales usando la biblioteca libvirt. Esto puede ser necesario si se han hecho cambios en la configuración o si el servicio no está funcionando correctamente.

## Reiniciar el servicio `iptables`

```bash
sudo systemctl restart iptables
```

Este comando reinicia el servicio `iptables`, que es el sistema de filtrado de paquetes de Linux. Reiniciar este servicio aplicará cualquier cambio de configuración reciente en las reglas de cortafuegos.

## Reiniciar el servicio `NetworkManager`

```bash
sudo systemctl restart NetworkManager
```

Este comando reinicia el servicio `NetworkManager`, que es responsable de gestionar todas las conexiones de red en el sistema. Reiniciarlo puede ayudar a resolver problemas de conectividad de red o aplicar cambios en la configuración de red.

```bash
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --reload
```

## Reiniciar servicios relacionados

```bash
sudo setenforce 0
sudo systemctl restart libvirtd
sudo systemctl restart nftables
sudo systemctl restart NetworkManager
```

> **Nota:** El comando `sudo systemctl restart libvirtd` está marcado como deprecado.

## Configuración de SELinux

```bash
sudo setenforce 0
sudo systemctl restart NetworkManager
sudo systemctl restart nftables
sudo systemctl restart virtqemud.service
```

Para verificar el estado del servicio:

```bash
sudo systemctl status virtqemud.service
```

## Pasos adicionales

1. **Desactiva SELinux temporalmente si estás depurando:**

    ```bash
    sudo setenforce 0
    ```

2. **Reinicia servicios de red (útil para bridges virtuales o DNS):**

    ```bash
    sudo systemctl restart NetworkManager
    ```

3. **Reinicia reglas de firewall (como nftables o firewalld):**

    ```bash
    sudo systemctl restart nftables
    # O reemplaza por firewalld si usas firewalld
    # sudo systemctl restart firewalld
    ```

4. **Reinicia todos los servicios relacionados con libvirt y QEMU:**

    ```bash
    sudo systemctl restart virtqemud.service virtlogd.service virtproxyd.service virtnetworkd.service virtstoraged.service
    ```

    Para reiniciar todos juntos:

    ```bash
    sudo systemctl restart virtqemud virtlogd virtproxyd virtnetworkd virtstoraged nftables NetworkManager
    ```

# Configuración de Red para el Clúster K3s

    ```bash
     sudo nft -f /etc/sysconfig/nftables.conf
     ```

## Verificación de conectividad

Realiza pruebas de conectividad con los siguientes comandos:

```bash
ping -c 4 10.17.4.21
ping -c 4 10.17.3.11
ping -c 4 10.17.3.1
ping -c 4 8.8.8.8
ping -c 4 192.168.0.30
ping -c 4 192.168.0.1
ping -c 4 10.17.5.10
ping -c 4 10.17.5.30
```

## Configuración de rutas necesarias para Kubernetes

### Máquinas donde debes configurar rutas manualmente

- **load_balancer1** (IP: 10.17.3.12)
- **load_balancer2** (IP: 10.17.3.13)

Estas máquinas están en la red `10.17.3.0/24`, por lo tanto requieren rutas hacia:

- La red de nodos master/worker → `10.17.4.0/24`
- La red de pods Flannel CNI → `10.42.0.0/16`
- La red del VIP del API server → `10.17.5.0/24`

### Comandos a ejecutar (en load_balancer1 y load_balancer2):

```bash
# 1. Ruta hacia red de nodos master/worker
sudo ip route add 10.17.4.0/24 via 10.17.3.1 dev eth0

# 2. Ruta hacia red de pods (red flannel CNI)
sudo ip route add 10.42.0.0/16 via 10.17.3.1 dev eth0

# 3. Ruta hacia la red del VIP del API server (k8s-api-lb)
sudo ip route add 10.17.5.0/24 via 10.17.3.1 dev eth0
```

### Configuración en la máquina `k8s-api-lb` (IP: 10.17.5.20):

Si vas a usar `kubectl` desde este nodo o deseas conectividad directa a pods, solo necesitas esta ruta:

```bash
sudo ip route add 10.42.0.0/16 via 10.17.5.1 dev eth0
```

💡 **Nota:** Esta ruta solo funcionará si `10.17.5.1` (pfSense o router) está configurado para enrutar a `10.42.0.0/16`, o si tienes una ruta adicional en el router hacia, por ejemplo, `10.17.4.21`.



## host servidor de virtualización
sudo ip route add 10.17.3.0/24 dev virbr_kube02
sudo ip route add 10.17.4.0/24 dev virbr_kube03



  

esta configuración es persistente?
esta es correcta?
nat_network_02
runcmd:
  - ip route add 10.17.3.0/24 via 192.168.0.1 dev eth0 
  - ip route add 10.17.4.0/24 via 192.168.0.1 dev eth0 
  - ip route add 10.17.5.0/24 via 192.168.0.1 dev eth0

## host servidor de virtualización
sudo ip route add 10.17.3.0/24 dev virbr_kube02
sudo ip route add 10.17.4.0/24 dev virbr_kube03

esta configuración es persistente ?
esta es correcta?
k8s-api-lb 
runcmd:
- ip route add 10.17.3.0/24 via 192.168.0.1 dev eth0
  - ip route add 10.17.4.0/24 via 192.168.0.1 dev eth0
  - ip route add 10.17.5.0/24 via 192.168.0.1 dev eth0
  - ip route add default via 192.168.0.1 dev eth0




runcmd:
  - ip route add 10.17.3.0/24 via 10.17.4.1 dev eth0 

  - ip route add 10.17.3.0/24 via 192.168.0.1 dev eth0 
  - ip route add 10.17.4.0/24 via 192.168.0.1 dev eth0 
  - ip route add 10.17.5.0/24 via 192.168.0.1 dev eth0




analiza y dame ordenamante las rutas correctas para haya conetividad entre estars redes y maquinas

10.17.3.0/24 → DNS/NTP/infra cloud-config 

10.17.4.0/24 → Clúster K3s: masters, workers y storage Ignition 

10.17.5.0/24 → VIPs de API y de Ingress

192.168.0.0/24 → Red física del host y acceso exterior puente br0

maquina virtual kvm/qmue librb 192.168.0.30 banaceador conecion con las mv y el host exterion y red fisica



_____

 configurados dos puertos públicos en tu router que redirigen a la máquina con IP interna 192.168.0.30:

Puerto público	Redirige a puerto	Protocolo	Servicio
8443	80	TCP	HTTP
2052	443	TCP	HTTPS

Entonces, para que tu servidor Python responda correctamente:

✅ Opción 1: Usar el puerto 80 para que funcione con el 8443 externo
Ejecuta este comando en la VM 192.168.0.30:

bash
Copiar
Editar
sudo python3 -m http.server 80 --bind 0.0.0.0
🔁 Esto servirá contenido HTTP desde http://<tu-ip-publica>:8443


nat network_02
sudo ip route add 10.17.4.0/24 via 10.17.3.1
sudo ip route add 10.17.5.0/24 via 10.17.3.1
sudo ip route add 192.168.0.0/24 via 10.17.3.1
