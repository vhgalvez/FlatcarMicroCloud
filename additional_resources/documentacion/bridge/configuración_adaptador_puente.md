# Configuración de un Adaptador Puente (Bridge) en Linux con NetworkManager

## Introducción

Este documento técnico proporciona una guía detallada sobre cómo configurar un adaptador puente (bridge) en un sistema Linux utilizando NetworkManager. Existen dos métodos principales: utilizando la herramienta de línea de comandos `nmcli` y editando manualmente los archivos de configuración de NetworkManager.

## Método 1: Usando nmcli

`nmcli` es una herramienta de línea de comandos para controlar NetworkManager, útil para scripts y automatización.

### Paso 1: Crear el puente br0

Para crear un puente, utiliza el siguiente comando:

```bash
sudo nmcli connection add type bridge ifname br0 con-name br0
```

Este comando crea un nuevo puente denominado `br0`.



## Paso 2: Agregar una interfaz esclava al puente

Para agregar una interfaz Ethernet como esclava al puente, usa este comando:

```bash
sudo nmcli connection add type ethernet ifname enp3s0f0 con-name bridge-slave-enp3s0f0 master br0
```

Este comando configura la interfaz enp3s0f0 para que funcione como parte del puente `br0`.


### Paso 3: Configurar el puente para obtener una dirección IP automáticamente

Configura el puente para obtener una dirección IP mediante DHCP:

```bash
sudo nmcli connection modify br0 ipv4.method auto ipv6.method ignore
```

## Paso 4: Reiniciar NetworkManager

Para aplicar las configuraciones, reinicia NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

### Paso 5: Activar la conexión del puente y la interfaz esclava

Para activar el puente, ejecuta:


```bash
sudo nmcli connection up br0
```

Para asegurarte de que la conexión de la interfaz esclava está activada, ejecuta:
    
```bash
sudo nmcli connection up bridge-slave-enp3s0f0
```
### Paso 6: Verificar el estado del puente

Para verificar que el puente está configurado correctamente, puedes comprobar su estado con:

```bash
nmcli device status
ip addr show br0
sudo brctl show
```

## Método 2: Editando Archivos de Configuración

Este método implica editar directamente los archivos de configuración de NetworkManager.

### Paso 1: Generar UUIDs para las conexiones

Antes de crear los archivos de configuración, es útil generar UUIDs únicos para cada conexión. Esto se puede hacer usando el comando `uuidgen` en la terminal. Ejecuta este comando dos veces para obtener dos UUIDs diferentes, uno para el puente y otro para la interfaz esclava:

```bash
uuidgen  # Genera un UUID para el puente br0
uuidgen  # Genera un UUID para la interfaz esclava enp3s0f0
```

### Paso 2: Crear el archivo de configuración del puente br0

Usa el UUID generado para crear un archivo en `/etc/NetworkManager/system-connections/` con el nombre `br0.nmconnection` y el siguiente contenido:

```ini
[connection]
id=br0
uuid=<UUID-GENERADO-PARA-BR0>  # Reemplaza <UUID-GENERADO-PARA-BR0> con el UUID generado en el paso 1
type=bridge
interface-name=br0

[ipv4]
method=auto

[ipv6]
method=ignore
```

### Paso 3: Crear el archivo de configuración para la interfaz esclava

Usa el segundo UUID generado para crear otro archivo en `/etc/NetworkManager/system-connections/` con el nombre `bridge-slave-enp3s0f0.nmconnection` y el siguiente contenid

```ini
[connection]
id=bridge-slave-enp3s0f0
uuid=<UUID-GENERADO-PARA-ESCLAVA>  # Reemplaza <UUID-GENERADO-PARA-ESCLAVA> con el UUID generado en el paso 1
type=ethernet
interface-name=enp3s0f0
master=br0
slave-type=bridge
```
### Paso 4: Reiniciar NetworkManager

Para aplicar las configuraciones, reinicia NetworkManager:
    
```bash
sudo systemctl restart NetworkManager
```

### Paso 5: Activar las conexiones

Para activar el puente y la conexión esclava, ejecuta:

```bash
sudo nmcli connection up br0
sudo nmcli connection up bridge-slave-enp3s0f0
```

### Paso 6: Verificar el estado del puente

Finalmente, verifica el estado de las interfaces y el puente con los siguientes comandos:

```bash
nmcli connection show
nmcli device status
ip addr show br0
sudo brctl show
```

![Verificar el estado del puente](file:///C:/Users/vhgal/Documents/desarrollo/IaC/cluster_openshift/terraform-openshift-kvm-deployment/additional_resources/image/bridge_configuration.png)

## Configuración de un Adaptador Puente (Bridge) en Rocky Linux KVM con Libvirt y Terraform

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
```

## Conclusión

Este documento detalla los pasos necesarios para configurar un adaptador puente en un sistema Linux utilizando NetworkManager, ya sea mediante la herramienta de línea de comandos `nmcli` o editando directamente los archivos de configuración. Ambos métodos son efectivos y la elección entre uno u otro puede depender de tus preferencias personales o necesidades específicas de automatización.

