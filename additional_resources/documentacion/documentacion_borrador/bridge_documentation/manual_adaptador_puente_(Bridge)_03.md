# Creación Manual de un Adaptador Puente (Bridge)

Puedes crear manualmente un adaptador puente (bridge) usando `nmcli` o directamente editando los archivos de configuración en `/etc/NetworkManager/system-connections/`. Aquí te dejo ambos métodos.

## Método 1: Usando nmcli

1. **Crear el puente `br0`:**

```bash
   sudo nmcli connection add type bridge ifname br0 con-name br0
```

### Agregar la interfaz esclava al puente br0:

```bash
sudo nmcli connection add type ethernet ifname enp3s0f0 con-name bridge-slave-enp3s0f0 master br0
```

### Configurar el puente para obtener una IP mediante DHCP:

```bash
sudo nmcli connection modify br0 ipv4.method auto ipv6.method ignore
```

### Activar la conexión del puente br0:

```bash
sudo nmcli connection up br0
```

### Verificar el estado del puente br0:

```bash
nmcli device status
ip addr show br0
sudo brctl show
```

## Método 2: Editando Archivos de Configuración

Crear el archivo de configuración para el puente br0:

Crear el archivo /etc/NetworkManager/system-connections/br0.nmconnection con el siguiente contenido:

```ini
[connection]
id=br0
uuid=e3bdeaea-c256-4592-aef2-8e4639b66dc2
type=bridge
interface-name=br0

[ethernet]

[bridge]

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
```

Crear el archivo de configuración para la interfaz esclava enp3s0f0:

Crear el archivo /etc/NetworkManager/system-connections/bridge-slave-enp3s0f0.nmconnection con el siguiente contenido:

```ini
[connection]
id=bridge-slave-enp3s0f0
uuid=92822580-241e-40ec-9f17-55649b2b0df3
type=ethernet
interface-name=enp3s0f0
master=br0
slave-type=bridge

[ethernet]

[bridge-port]
```

### Reiniciar NetworkManager para aplicar las configuraciones:

```bash
sudo systemctl restart NetworkManager
```

Verificar el estado de las interfaces y el puente:

```bash
nmcli device status
ip addr show br0
sudo brctl show
```