# Configuración de un Adaptador Puente en Rocky Linux 9 para Uso con libvirt y KVM

Esta guía proporciona una serie de pasos detallados para configurar un adaptador puente en Rocky Linux 9, reflejando una comprensión avanzada de las prácticas de sistemas y redes Linux.

## 1. Preparación del Sistema

### Instalación de Herramientas Necesarias

Para gestionar puentes e interfaces de red adecuadamente, es esencial instalar `bridge-utils` y `net-tools`. Rocky Linux utiliza `dnf` como gestor de paquetes:

```bash
sudo dnf install bridge-utils net-tools
```

## 2. Configuración del Puente de Red
Crear el Archivo de Configuración del Puente
A pesar de que Rocky Linux usa NetworkManager por defecto, para configuraciones estables y detalladas de puentes es recomendable manejarlos a través de archivos en /etc/sysconfig/network-scripts/:

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-br0
```

Incluye lo siguiente en el archivo `ifcfg-br0`:

```plaintext
DEVICE=br0
TYPE=Bridge
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.0.27
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=8.8.8.8
```

Configurar la Interfaz Física

La interfaz física que se usará como parte del puente debe configurarse en modo manual para evitar conflictos de configuración IP:

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-enp3s0
```

Asegúrate de que el contenido sea similar a:

```plaintext
DEVICE=enp3s0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
NM_CONTROLLED=no
BRIDGE=br0
```

## 3. Reinicio de los Servicios de Red

Aplica los cambios reiniciando los servicios de red:

```bash
sudo systemctl restart NetworkManager
```

## 4. Verificación de la Configuración del Puente

Verifica que el puente esté correctamente configurado y operativo:

```bash
ip addr show br0
```
Deberías ver la dirección IP asignada junto con otros detalles de configuración relevantes.

## 5. Integración con libvirt

Asegúrate de que libvirt está configurado para usar el puente correctamente. Instala libvirt y KVM si aún no están en el sistema:

```bash 
sudo dnf install libvirt qemu-kvm
sudo systemctl enable --now libvirtd
```
Configura las máquinas virtuales para utilizar br0 como su adaptador de red:


```xml
<network>
  <bridge name='br0'/>
</network>
```


## 6. Integración con Terraform
Configura un recurso de red para Terraform que use el puente br0:

**Red kube_network_01 - Bridge Network - Rocky Linux 9.3**

```hcl
resource "libvirt_network" "kube_network_01" {
  name   = "kube_network_01"
  mode   = "bridge"
  bridge = "br0"
}
```


##  7. Resolución de Problemas
Si encuentras errores durante la configuración o el uso, verifica los permisos y los registros de libvirt:


```bash
sudo journalctl -u libvirtd
```

Revisa también la configuración de SELinux, que puede necesitar ajustes si está bloqueando algunas operaciones de red.

Con estos pasos, serás capaz de configurar un puente de red en Rocky Linux 9, optimizando así el rendimiento y la gestión de tus máquinas virtuales en un entorno KVM utilizando libvirt.



# ver interfaces de red físicas
lspci | grep Ethernet
