
# Crear el puente br0


```bash
sudo nmcli connection add type bridge ifname br0 con-name br0
```

# Agregar una interfaz esclava al puente

```bash
sudo nmcli connection add type ethernet ifname enp3s0f0 con-name bridge-slave-enp3s0f0 master br0
```

# Configurar el puente para obtener una dirección IP automáticamente

```bash
sudo nmcli connection modify br0 ipv4.method auto ipv6.method ignore
```

# Activar la conexión del puente

```bash
sudo nmcli connection up br0
```

# Verificar el estado del puente

```bash
nmcli device status
```

```bash
ip addr show br0
```

```bash
sudo brctl show
```

# Configurar el puente para que se inicie automáticamente terraform

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
```
