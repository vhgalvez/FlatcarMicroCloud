Entendido. Aquí tienes un resumen completo de la hipótesis del problema que estamos enfrentando y las soluciones propuestas.

Resumen Completo: Hipótesis del Problema y Soluciones
1. Hipótesis del Problema Principal:

La principal hipótesis es que las máquinas virtuales (VMs) conectadas a los puentes virtuales virbr_kube02 y virbr_kube03 (como infra-cluster y master1) no tienen acceso consistente o total a Internet/red externa debido a un conflicto de enrutamiento en el servidor host virtualizacion-server, no por el firewall en sí.

Evidencia que respalda esta hipótesis:

Pings inconsistentes de las VMs:
Las VMs en virbr_kube02 y virbr_kube03 (ej. infra-cluster, master1) pueden comunicarse perfectamente con redes internas (10.17.x.x, 192.168.0.30) y con el balanceador de carga (k8s-api-lb).
Sin embargo, estas VMs fallan al hacer ping a 192.168.0.1 (el router físico) y a 8.8.8.8 (Internet), mostrando 100% de pérdida de paquetes.
Contraste con k8s-api-lb:
La VM k8s-api-lb (conectada al puente br0) tiene conectividad perfecta a Internet (ping a 8.8.8.8 exitoso), lo que demuestra que las reglas de nftables y el NAT del host sí funcionan para al menos una de las redes virtuales.
Conflicto de IPs y rutas en el Host (ip a y nmcli connection):
La interfaz enp3s0f0 del host tiene la IP estática deseada (192.168.0.40) y es la interfaz de salida prevista.
La interfaz enp3s0f1 está adquiriendo MÚLTIPLES direcciones IP dinámicas de tu router (ej., 192.168.0.61, 192.168.0.14, 192.168.0.18, 192.168.0.19). Esto es altamente problemático.
La interfaz enp4s0f0 también está adquiriendo una dirección IP dinámica (ej., 192.168.0.21).
La presencia de múltiples interfaces obteniendo IPs en la misma subred (192.168.0.0/24) automáticamente crea múltiples "rutas predeterminadas" (default routes) en la tabla de enrutamiento del host. Un sistema solo necesita (y prefiere) una única ruta predeterminada para el tráfico hacia Internet.
Reglas de Firewall (nftables.conf) Correctas:
Hemos revisado tu configuración de nftables y las reglas para el reenvío de tráfico (forward) y el enmascaramiento (masquerade) de todas las redes virtuales (10.17.3.0/24, 10.17.4.0/24, 192.168.0.0/24) a través de enp3s0f0 son correctas. Esto descarta el firewall como la causa directa del problema de conectividad de Internet.
En resumen: El host está confundido sobre por dónde enviar el tráfico que viene de las VMs y necesita salir a Internet, debido a que varias de sus interfaces físicas están intentando ser la "puerta de enlace predeterminada".

2. Soluciones Posibles (Pasos para Implementar y Verificar):

La solución se centra en eliminar la confusión de enrutamiento en el host.

Paso 1: Clarificar el Propósito de Cada Interfaz Física del Host (Crucial)

enp3s0f0 (192.168.0.40): Asumimos que esta es la única interfaz principal del host para acceder a la LAN/Internet y por donde debe salir todo el tráfico NAT de las VMs.
enp3s0f1 y enp4s0f0: Necesitamos determinar si estas interfaces tienen algún propósito específico y diferente para el host (ej. una red de gestión separada, un almacenamiento dedicado, etc.).
Si NO tienen un propósito específico que requiera una IP en el host o una ruta predeterminada: Deben ser deshabilitadas a nivel de IP.
Si SÍ tienen un propósito específico: Deben configurarse estáticamente (si es posible) y sin adquirir una ruta predeterminada, o con una métrica muy alta para que no interfieran con la ruta principal.
Paso 2: Deshabilitar o Configurar Correctamente las Conexiones No Necesarias (si el propósito es solo enp3s0f0 para Internet)

Para enp3s0f1-dhcp y enp4s0f0-dhcp:
Bash

# Deshabilitar obtención de IP y limpiar IPs en enp3s0f1
sudo nmcli connection modify "enp3s0f1-dhcp" ipv4.method disabled
sudo nmcli connection modify "enp3s0f1-dhcp" ipv4.addresses ""
sudo nmcli connection down "enp3s0f1-dhcp"

# Repetir para enp4s0f0
sudo nmcli connection modify "enp4s0f0-dhcp" ipv4.method disabled
sudo nmcli connection modify "enp4s0f0-dhcp" ipv4.addresses ""
sudo nmcli connection down "enp4s0f0-dhcp"

# (Opcional, si estás seguro de no usar nunca más esas configuraciones)
# sudo nmcli connection delete "enp3s0f1-dhcp"
# sudo nmcli connection delete "enp4s0f0-dhcp"
Paso 3: Reiniciar Servicios Clave en el Host

Reiniciar NetworkManager para que aplique los cambios:
Bash

sudo systemctl restart NetworkManager
Reiniciar nftables para asegurar que las reglas del firewall se carguen sobre la nueva configuración de red limpia:
Bash

sudo systemctl restart nftables
sudo nft -f /etc/sysconfig/nftables.conf # Recargar explícitamente el archivo
Paso 4: Verificar la Tabla de Enrutamiento del Host

Después de los pasos anteriores, ejecuta este comando en el host:
Bash

ip route show
Objetivo: Deberías ver UNA ÚNICA línea que comience con default via 192.168.0.1 dev enp3s0f0. Si todavía ves múltiples rutas predeterminadas, es posible que sea necesario un reinicio completo del host o una investigación más profunda de configuraciones persistentes.
Paso 5: Probar la Conectividad de las VMs

Desde infra-cluster y master1, vuelve a ejecutar los pings:
Bash

ping -c 4 10.17.4.21; ping -c 4 10.17.3.11; ping -c 4 10.17.3.1; ping -c 4 8.8.8.8; ping -c 4 192.168.0.30; ping -c 4 192.168.0.1
Objetivo: Todos los pings (incluido el de 8.8.8.8 y 192.168.0.1) deberían ser exitosos (0% packet loss).
Paso 6: (Consideración Futura - Asignación de IPs Fijas a VMs)

Para un entorno de producción, es muy recomendable asignar IPs fijas a tus VMs (usando cloud-init con Terraform).
Si haces esto, asegúrate de que los rangos DHCP de tus puentes virtuales Libvirt (virbr_kube02, virbr_kube03) no solapen las IPs estáticas que asignas a las VMs. Puedes modificar los rangos DHCP de las redes Libvirt usando virsh net-edit <nombre_de_red>.
Por favor, dime cuál es el propósito de enp3s0f1 y enp4s0f0 para poder darte las instrucciones más precisas en el Paso 2.