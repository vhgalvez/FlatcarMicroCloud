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

### Paso 2: Agregar una interfaz esclava al puente

Para agregar una interfaz Ethernet como esclava al puente, usa este comando:

```bash
sudo nmcli connection add type ethernet ifname enp3s0f0 con-name bridge-slave-enp3s0f0 master br0
```

Este comando configura la interfaz `enp3s0f0` para que funcione como parte del puente `br0`.

### Paso 3: Configurar el puente para obtener una dirección IP automáticamente

Configura el puente para obtener una dirección IP mediante DHCP:

```bash
sudo nmcli connection modify br0 ipv4.method auto ipv6.method ignore
```

### Paso 4: Reiniciar NetworkManager (nmcli)

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

### Paso 6: Verificar el estado del puente (nmcli)

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

Usa el segundo UUID generado para crear otro archivo en `/etc/NetworkManager/system-connections/` con el nombre `bridge-slave-enp3s0f0.nmconnection` y el siguiente contenido:

```ini
[connection]
id=bridge-slave-enp3s0f0
uuid=<UUID-GENERADO-PARA-ESCLAVA>  # Reemplaza <UUID-GENERADO-PARA-ESCLAVA> con el UUID generado en el paso 1
type=ethernet
interface-name=enp3s0f0
master=br0
slave-type=bridge
```

### Paso 4: Reiniciar NetworkManager (archivos)

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

### Paso 6: Verificar el estado del puente (archivos)

Finalmente, verifica el estado de las interfaces y el puente con los siguientes comandos:

```bash
nmcli connection show
nmcli device status
ip addr show br0
sudo brctl show
```

## Configuración de Redes Puenteadas para WAN y LAN

### Creación de los Puentes en el Host KVM

#### Puente para WAN (br0)

Utilizar la interfaz física `enp3s0f0` para el puente WAN:

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

#### Puente para LAN (br1)

Utilizar la interfaz física `enp3s0f1` para el puente LAN:

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

### Verificación de la Configuración de Red

Ejecuta los siguientes comandos para verificar que los puentes se crearon y están activos:

```bash
# Verificar las conexiones activas
sudo nmcli connection show

# Verificar las interfaces de red
ip addr show
```

### Resultado Esperado

- `br0` con la IP `192.168.100.1/24` y la interfaz `enp3s0f0` como esclava.
- `br1` con la IP `192.168.1.1/24` y la interfaz `enp3s0f1` como esclava.

## Configuración de Terraform para Redes Puenteadas

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

### Inicialización y Despliegue de Terraform

#### Inicializar Terraform

```bash
sudo terraform init --upgrade
```

#### Planificar la Infraestructura

```bash
sudo terraform plan
```

#### Aplicar la Configuración

```bash
sudo terraform apply
```

### Resultado Esperado

- pfSense será desplegado con:

  - Red **WAN** conectada al puente `br0` (`192.168.100.0/24`).
  - Red **LAN** conectada al puente `br1` (`192.168.1.0/24`).

#### Verificar el Despliegue

- Accede a la consola VNC para completar la instalación de pfSense.
- Configura la interfaz **WAN** y **LAN** desde la interfaz de instalación.

### Verificación Final

Después de la instalación:

- La interfaz **WAN** de pfSense debe obtener `192.168.100.1/24`.
- La interfaz **LAN** debe asignarse en `192.168.1.1/24`.

#### Prueba Final

Comprueba que las máquinas conectadas al puente `br1` puedan acceder a la red LAN.



_____


# Paso a paso para configurar un bridge (br0) en Rocky/AlmaLinux para KVM

# 1. Instalar herramientas necesarias
sudo dnf install bridge-utils -y

# 2. Crear conexión bridge br0 y asignar IP estática
sudo nmcli connection add type bridge autoconnect yes con-name br0 ifname br0
sudo nmcli connection modify br0 \
  ipv4.method manual \
  ipv4.addresses 192.168.0.20/24 \
  ipv4.gateway 192.168.0.1 \
  ipv4.dns "192.168.0.1 8.8.8.8"

# 3. Agregar interfaz física como esclava del bridge
sudo nmcli connection add type ethernet slave-type bridge \
  con-name br0-port1 ifname enp3s0f0 master br0

# 4. Activar el bridge
sudo nmcli connection up br0

# 5. Verificar la configuración
ip a | grep br0

# Alternativa persistente con archivos (NetworkManager)
# Archivo: /etc/NetworkManager/system-connections/br0.nmconnection

[connection]
id=br0
type=bridge
interface-name=br0
autoconnect=true

[bridge]
stp=false

[ipv4]
method=manual
address1=192.168.0.20/24,192.168.0.1
dns=192.168.0.11;
dns-search=

[ipv6]
method=ignore

# Archivo: /etc/NetworkManager/system-connections/enp3s0f0.nmconnection

[connection]
id=enp3s0f0
type=ethernet
interface-name=enp3s0f0
master=br0
slave-type=bridge
autoconnect=true

[ipv4]
method=disabled

[ipv6]
method=ignore

# Reiniciar NetworkManager
dnf reload NetworkManager
nmcli connection reload
nmcli connection up br0

# Resultado esperado: br0 con IP 192.168.0.20 y enp3s0f0 sin IP
