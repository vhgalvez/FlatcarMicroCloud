Documentación: Configuración de un Switch Virtual con Bridge y Terraform para Libvirt

Objetivo: Crear un switch virtual (br0) en el sistema operativo host (Rocky Linux) y configurar una red Libvirt (kube_network_01) para que las máquinas virtuales conectadas a ella se integren directamente en la red física (LAN). Esto permite la comunicación directa entre las VMs y otros dispositivos en la LAN, eliminando la necesidad de NAT para esta red.

Entorno:

Sistema Operativo Host: Rocky Linux
Herramienta de Gestión de Red: NetworkManager (nmcli)
Virtualización: Libvirt
Infraestructura como Código: Terraform
Pasos en el Host (Rocky Linux):

Identificar la Interfaz de Red Física:

Ejecuta el siguiente comando para listar las interfaces de red disponibles en tu sistema:
Bash

ip a
Identifica la interfaz que está conectada a tu red LAN y que probablemente tiene una dirección IP asignada (por ejemplo, enp4s0f0). Anota este nombre, ya que lo usarás en los siguientes comandos.
Crear la Interfaz de Puente (br0):

Utiliza nmcli para crear una nueva conexión de tipo puente llamada br0. Este comando crea la interfaz virtual del puente:
Bash

sudo nmcli con add type bridge con-name br0 ifname br0 stp no
type bridge: Especifica que el tipo de conexión es un puente.
con-name br0: Asigna el nombre br0 a la conexión de NetworkManager para este puente.
ifname br0: Asigna el nombre br0 a la interfaz de red virtual del puente en el sistema operativo.
stp no: Deshabilita el Protocolo de Árbol de Expansión (Spanning Tree Protocol) para este puente. En la mayoría de los entornos domésticos o de laboratorio, no es necesario habilitarlo.
Crear una Conexión Esclava para la Interfaz Física:

Asocia la interfaz de red física identificada en el Paso 1 (enp4s0f0 en este ejemplo) como un "esclavo" del puente br0. Esto conecta la interfaz física al switch virtual:
Bash

sudo nmcli con add type ethernet ifname enp4s0f0 master br0 con-name br0-slave0
type ethernet: Especifica que el tipo de conexión es Ethernet.
ifname enp4s0f0: Reemplaza enp4s0f0 con el nombre de tu interfaz física.
master br0: Especifica que esta conexión Ethernet es un esclavo del puente br0.
con-name br0-slave0: Asigna un nombre a la conexión de NetworkManager para esta interfaz esclava.
Desactivar la Conexión IP en la Interfaz Física:

Si tu interfaz física tenía una dirección IP asignada directamente, desactiva su conexión en NetworkManager para que la dirección IP se asigne ahora a la interfaz del puente:
Bash

sudo nmcli con down enp4s0f0
Reemplaza enp4s0f0 si tu interfaz física tiene un nombre diferente.
Activar la Conexión del Puente:

Activa la conexión del puente br0. Esto levanta la interfaz del puente y hace que tome la configuración IP (si está configurada para DHCP) o esté lista para una configuración estática:
Bash

sudo nmcli con up br0
Verificar la Configuración del Puente:

Utiliza los siguientes comandos para verificar que el puente se ha creado y configurado correctamente:
Bash

ip a | grep br0
brctl show
ip a | grep br0: Muestra la información de la interfaz br0, incluyendo su dirección IP (si la tiene).
brctl show: Muestra los puentes existentes en el sistema y los puertos (interfaces) que están asociados a ellos. Deberías ver tu interfaz física (enp4s0f0) listada como un puerto del puente br0.
Pasos en Terraform:

Localizar la Definición de la Red kube_network_01:

Abre tus archivos Terraform y busca el bloque de código que define el recurso libvirt_network con el nombre "kube_network_01" (o el valor de var.rocky9_network_name si ese es el nombre que se está utilizando para esta red). Debería tener una estructura similar a la siguiente:
Terraform

resource "libvirt_network" "kube_network_01" {
  name        = var.rocky9_network_name # o "kube_network_01"
  mode        = "nat"
  bridge      = "virbr_kube01"
  domain      = "kube.internal"
  autostart   = true
  addresses   = ["10.17.5.0/24"]
}
Modificar la Definición de la Red kube_network_01:

Reemplaza el bloque de código anterior con la siguiente configuración para cambiar la red al modo bridge y conectarla al puente br0:
Terraform

resource "libvirt_network" "kube_network_01" {
  name        = var.rocky9_network_name # o "kube_network_01"
  mode        = "bridge"
  bridge      = "br0"
  domain      = "kube.internal"
  autostart   = true
  # Elimina o comenta la línea de 'addresses'
  # addresses   = ["10.17.5.0/24"]
}
mode = "bridge": Cambia el modo de la red de NAT a puente.
bridge = "br0": Especifica que esta red Libvirt utilizará el puente br0 que creamos en el sistema operativo host.
Se ha eliminado o comentado la línea addresses, ya que en modo bridge, libvirt no gestiona directamente el rango de IPs. Las VMs obtendrán IPs de la red física.
Aplicar los Cambios con Terraform:

Navega al directorio donde se encuentran tus archivos Terraform en la terminal y ejecuta el siguiente comando para aplicar los cambios:
Bash

terraform apply
Revisa el plan de cambios que Terraform te mostrará y confirma (yes) para aplicar la configuración. Esto destruirá y recreará la red kube_network_01 con la nueva configuración.
Después de la Aplicación:

Las máquinas virtuales conectadas a la red kube_network_01 ahora estarán conectadas directamente al puente br0.
Estas máquinas virtuales intentarán obtener direcciones IP de tu red LAN a través de DHCP (si está habilitado en tu router) o necesitarán ser configuradas con direcciones IP estáticas válidas dentro de la subred de tu red LAN (192.168.0.0/24 en tu caso).
Una vez que las máquinas virtuales tengan direcciones IP en la red LAN, podrán comunicarse directamente con otros dispositivos en la misma red, incluyendo otras máquinas virtuales (como las de kube_network_03 si también están en la misma red física).
¡Espero que esta documentación detallada te sea útil para replicar esta configuración y entender el proceso! Si tienes alguna otra pregunta, no dudes en consultarme.


# Red MVS freeIPA1 firewall-cmd
nftables
```bash
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-service=dns --permanent
sudo firewall-cmd --zone=public --add-service=dhcpv6-client --permanent
sudo firewall-cmd --zone=public --add-service=ntp --permanent
sudo firewall-cmd --zone=public --add-port=53/udp --permanent
sudo firewall-cmd --zone=public --add-port=53/tcp --permanent
sudo firewall-cmd --zone=public --add-source=10.17.4.0/24 --permanent
sudo firewall-cmd --zone=public --add-source=10.17.3.0/24 --permanent
sudo firewall-cmd --zone=public --set-target=ACCEPT --permanent
sudo firewall-cmd --reload
```


# Verificar configuración

```bash
sudo firewall-cmd --list-all
```

lo que queriamos corregiuir el error de doble nat causa perdida de conectivad

¡Hola! ¡Exactamente! El principal motivo detrás de la implementación del modo bridge para kube_network_01 es corregir el error de la doble NAT, que puede causar problemas de conectividad y dificultar la comunicación entre diferentes partes de tu infraestructura.

Aquí te explico cómo la doble NAT puede generar problemas y cómo el modo bridge los soluciona en este contexto:

Problema de la Doble NAT:

Escenario: Inicialmente, si tu máquina k8s-api-lb estuviera conectada a una red Libvirt en modo NAT (como kube_network_01 originalmente con la IP 10.17.5.50) y necesitara comunicarse con los nodos Kubernetes que también están en otra red NAT (kube_network_03 con IPs 10.17.4.x), el tráfico tendría que pasar por dos capas de Traducción de Direcciones de Red (NAT).

¿Por qué es un problema?

Rutas Complejas: Configurar el enrutamiento y el reenvío de puertos a través de múltiples capas de NAT puede volverse complicado y propenso a errores.
Problemas de Conectividad: Ciertos protocolos o tipos de comunicación pueden no funcionar correctamente a través de múltiples capas de NAT. Por ejemplo, protocolos que requieren conexiones iniciadas desde la red interna pueden tener dificultades para establecerse a través de múltiples NATs.
Latencia Adicional: Cada capa de NAT introduce un pequeño retraso en el procesamiento del tráfico.
Dificultad en el Diagnóstico: Rastrear problemas de conectividad a través de múltiples NATs puede ser más difícil.
Solución con el Modo Bridge:

Integración Directa: Al cambiar kube_network_01 al modo bridge y conectarlo a tu red LAN (192.168.0.0/24), cualquier máquina virtual conectada a esta red (como k8s-api-lb con la IP 192.168.0.50) obtiene una dirección IP directamente de tu LAN.

Comunicación Directa: Ahora, k8s-api-lb está en la misma red lógica que otros dispositivos de tu LAN. Para comunicarse con los nodos Kubernetes (que están en la red NAT 10.17.4.0/24), el tráfico solo necesita ser enrutado entre estas dos redes. Esto elimina la necesidad de una segunda capa de NAT para la comunicación entre k8s-api-lb y la LAN.

Enrutamiento Simplificado: La comunicación entre la LAN (192.168.0.0/24) y la red NAT de los nodos (10.17.4.0/24) se gestiona a nivel de tu router LAN (para el tráfico desde la LAN hacia la red NAT) y por el gateway NAT proporcionado por Libvirt (10.17.4.1) para el tráfico desde los nodos hacia la LAN. Esto es mucho más sencillo que lidiar con dos capas de NAT.

En resumen, la implementación del modo bridge para kube_network_01 se realizó para:

Eliminar la doble NAT que habría ocurrido si k8s-api-lb permanecía en una red NAT separada y necesitaba comunicarse con otras redes NAT.
Simplificar la arquitectura de red y el enrutamiento.
Mejorar la confiabilidad y la conectividad entre los diferentes componentes de tu infraestructura al evitar las posibles complicaciones de la doble NAT.


vrrp_instance VI_1 {
    state MASTER
    interface br0 # <----- CAMBIO AQUÍ
    virtual_router_id 51
    priority 100  # Prioridad más alta para el nodo principal
    advert_int 1  # Intervalo de anuncios VRRP
    authentication {
        auth_type PASS
        auth_pass 12345678
    }

    virtual_ipaddress {
        192.168.0.55 # <----- CAMBIO AQUÍ
    }

    track_script {
        script "pidof haproxy"  # Monitoriza si HAProxy está corriendo
        interval 2
    }
}

# Configuración para el nodo de respaldo (para otros Load Balancers)
vrrp_instance VI_2 {
    state BACKUP
    interface br0 # <----- CAMBIO AQUÍ
    virtual_router_id 52  # Cambiar VRID para evitar duplicados
    priority 90  # Menor prioridad para el nodo de respaldo
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 12345678
    }

    virtual_ipaddress {
        192.168.0.55 # <----- CAMBIO AQUÍ
    }

    track_script {
        script "pidof haproxy"  # Monitoriza si HAProxy está corriendo
        interval 2
    }
}
Explicación de los Cambios:

interface br0: Hemos cambiado la interfaz de eth0 a br0. Esto asegura que Keepalived esté operando en la interfaz del puente que está conectada a tu red LAN. Si por alguna razón tu interfaz LAN en el host tiene un nombre diferente, debes usar ese nombre en lugar de br0.
virtual_ipaddress 192.168.0.55: Hemos actualizado la dirección IP virtual en ambos bloques vrrp_instance a la nueva IP (192.168.0.55) que reside en tu red LAN.
Una vez que apliques estos cambios al archivo keepalived.conf.j2 y ejecutes el playbook de Ansible, Keepalived configurará la IP virtual 192.168.0.55 en la interfaz br0 de tu servidor k8s-api-lb.

Asegúrate de que el host donde se ejecuta Ansible pueda acceder al host k8s-api-lb y que la variable hosts: haproxy_keepalived en tu playbook apunte correctamente a ese host.