# Creación de redes puenteadas (br0 para WAN y br1 para LAN) utilizando nmcli

## 1. Creación de los puentes en el host KVM

### Puente para WAN (br0)
Utilizar la interfaz física `enp3s0f0` para el puente WAN.

```bash
# Crear el puente br0 (WAN)
sudo nmcli connection add type bridge con-name br0 ifname br0

# Añadir la interfaz física enp3s0f0 como esclava del puente br0
sudo nmcli connection add type bridge-slave con-name br0-enp3s0f0 ifname enp3s0f0 master br0

# Configurar IP estática en br0
sudo nmcli connection modify br0 ipv4.addresses 192.168.100.1/24 ipv4.method manual

# Activar el puente
sudo nmcli connection up br0
```

### Puente para LAN (br1)
Utilizar la interfaz física `enp3s0f1` para el puente LAN.

```bash
# Crear el puente br1 (LAN)
sudo nmcli connection add type bridge con-name br1 ifname br1

# Añadir la interfaz física enp3s0f1 como esclava del puente br1
sudo nmcli connection add type bridge-slave con-name br1-enp3s0f1 ifname enp3s0f1 master br1

# Configurar IP estática en br1
sudo nmcli connection modify br1 ipv4.addresses 192.168.1.1/24 ipv4.method manual

# Activar el puente
sudo nmcli connection up br1
```

## 2. Verificación de la configuración de red
Ejecuta los siguientes comandos para verificar que los puentes se crearon y están activos:

```bash
# Verificar las conexiones activas
sudo nmcli connection show

# Verificar las interfaces de red
ip addr show
```

### Resultado esperado:
- `br0` con la IP `192.168.100.1/24` y la interfaz `enp3s0f0` como esclava.
- `br1` con la IP `192.168.1.1/24` y la interfaz `enp3s0f1` como esclava.

## 3. Configuración de Terraform (main.tf)
Asegúrate de que el archivo `main.tf` esté configurado correctamente para usar los puentes `br0` y `br1`:

```hcl
# Configuración de la red WAN (puente br0)
resource "libvirt_network" "wan" {
  name      = "wan_network"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
}

# Configuración de la red LAN (puente br1)
resource "libvirt_network" "lan" {
  name      = "lan_network"
  mode      = "bridge"
  bridge    = "br1"
  autostart = true
}
```

## 4. Inicialización y despliegue de Terraform

### Inicializar Terraform
```bash
sudo terraform init --upgrade
```

### Planificar la infraestructura
```bash
sudo terraform plan
```

### Aplicar la configuración
```bash
sudo terraform apply
```

## 5. Resultado esperado
pfSense será desplegado con:
- Red **WAN** conectada al puente `br0` (`192.168.100.0/24`).
- Red **LAN** conectada al puente `br1` (`192.168.1.0/24`).

### Verificar el despliegue:
- Accede a la consola VNC para completar la instalación de pfSense.
- Configura la interfaz **WAN** y **LAN** desde la interfaz de instalación.

## 6. Verificación final
Después de la instalación:

- La interfaz **WAN** de pfSense debe obtener `192.168.100.1/24`.
- La interfaz **LAN** debe asignarse en `192.168.1.1/24`.

### Prueba final:
Comprueba que las máquinas conectadas al puente `br1` puedan acceder a la red LAN. 

---
**Fin del documento**
