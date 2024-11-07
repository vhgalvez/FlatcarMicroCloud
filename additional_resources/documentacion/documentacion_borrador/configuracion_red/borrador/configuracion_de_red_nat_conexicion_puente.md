
Documentación Técnica para Configuración de Comunicación entre Redes NAT y una Red Bridge en KVM
Este documento proporciona una guía detallada sobre cómo configurar la comunicación entre redes NAT y una red puente (bridge) en un entorno KVM. La configuración se realiza en un servidor KVM físico y sus máquinas virtuales (VMs).

1. Configuración de la Red Bridge (Bridge Network)
Paso 1: Asegurar que la Red Bridge esté Configurada y Funcionando
La red bridge (br0) debe estar configurada y operativa. En tu configuración de Terraform, esto se ha definido como:

terraform
Copiar código
# Red br0 - Bridge Network - Rocky Linux 9.3
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
2. Habilitar el Reenvío de IP en el Servidor KVM
El reenvío de IP debe estar habilitado en el servidor KVM para permitir la comunicación entre las redes NAT y la red bridge.

Paso 2: Editar el Archivo sysctl.conf
En el servidor KVM físico (Servidor KVM: ProLiant DL380 G7), edita el archivo /etc/sysctl.conf y añade la siguiente línea:

sh
Copiar código
net.ipv4.ip_forward = 1
Paso 3: Aplicar los Cambios
Ejecuta el siguiente comando para aplicar los cambios:

sh
Copiar código
sudo sysctl -p
3. Configurar el Enrutamiento entre las Redes
Necesitarás agregar las reglas de enrutamiento necesarias para permitir la comunicación entre las redes NAT y la red bridge utilizando iptables.

Paso 4: Agregar Reglas de Enrutamiento
Configuración para nat_network_02
sh
Copiar código
# En el servidor KVM físico
sudo iptables -t nat -A POSTROUTING -s 10.17.3.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
Configuración para nat_network_03
sh
Copiar código
# En el servidor KVM físico
sudo iptables -t nat -A POSTROUTING -s 10.17.4.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr1 -o br0 -j ACCEPT
4. Persistir las Reglas de iptables
Para asegurar que las reglas de iptables se mantengan después de un reinicio, utiliza iptables-save y iptables-restore.

Paso 5: Guardar las Reglas Actuales
sh
Copiar código
# En el servidor KVM físico
sudo iptables-save > /etc/iptables/rules.v4
Paso 6: Configurar la Restauración de las Reglas al Inicio
En sistemas basados en Debian/Ubuntu, puedes hacerlo añadiendo el siguiente comando en el archivo /etc/network/interfaces o en un script de inicio:

sh
Copiar código
iptables-restore < /etc/iptables/rules.v4
5. Configurar las Rutas en las Máquinas Virtuales
Asegúrate de que las máquinas virtuales en las redes NAT sepan cómo llegar a la red bridge. Esto generalmente implica agregar rutas estáticas en las máquinas virtuales.

Paso 7: Agregar Rutas Estáticas
Ejemplo en una Máquina Virtual en nat_network_02
En la VM freeipa1:

sh
Copiar código
sudo ip route add 192.168.0.0/24 via 10.17.3.1
Aquí, 10.17.3.1 es la puerta de enlace de la red NAT nat_network_02.

6. Verificar la Conectividad
Finalmente, verifica la conectividad entre las máquinas virtuales en las redes NAT y la red bridge utilizando herramientas como ping.

Paso 8: Comprobar la Conexión
En la VM freeipa1 en nat_network_02:

sh
Copiar código
ping 192.168.0.35
Este comando debería hacer ping a la IP del nodo bastión bastion1 en la red bridge br0.

Resumen
Para lograr la comunicación entre redes NAT y la red bridge (bridge) en tu entorno KVM, debes:

Configurar correctamente la red bridge (br0).
Habilitar el reenvío de IP en el servidor KVM.
Configurar las reglas de iptables para enmascarar y permitir el tráfico entre las redes.
Persistir las reglas de iptables.
Agregar las rutas necesarias en las máquinas virtuales.
Verificar la conectividad.
Siguiendo estos pasos, podrás establecer comunicación entre tus redes NAT y la red bridge en tu entorno KVM.

Para cualquier duda o problema, por favor, abre un issue en el repositorio o contacta al mantenedor del proyecto.

Mantenedor del Proyecto: Victor Galvez







Paso 1: Crear el Directorio
Primero, crea el directorio /etc/iptables:

sh
Copiar código
sudo mkdir -p /etc/iptables
Paso 2: Guardar las Reglas de iptables
Luego, guarda las reglas de iptables en el archivo rules.v4:

sh
Copiar código
sudo iptables-save > /etc/iptables/rules.v4
Paso 3: Configurar el Sistema para Restaurar las Reglas al Inicio
Asegúrate de que las reglas de iptables se restauren automáticamente al iniciar el sistema. En Rocky Linux, puedes hacerlo utilizando iptables-restore en un script de inicio o configurando el servicio de iptables.

Opción 1: Usar un Script de Inicio
Crea un script de inicio, por ejemplo, /etc/network/if-pre-up.d/iptables:

sh
Copiar código
sudo nano /etc/network/if-pre-up.d/iptables
Añade las siguientes líneas al script:

sh
Copiar código
#!/bin/sh
/sbin/iptables-restore < /etc/iptables/rules.v4
Guarda el archivo y hazlo ejecutable:

sh
Copiar código
sudo chmod +x /etc/network/if-pre-up.d/iptables
Opción 2: Usar un Servicio de iptables
Rocky Linux puede utilizar firewalld o un servicio específico de iptables. A continuación, se muestra cómo configurarlo usando un servicio de iptables.

Crea un archivo de servicio para iptables:

sh
Copiar código
sudo nano /etc/systemd/system/iptables-restore.service
Añade las siguientes líneas al archivo del servicio:

ini
Copiar código
[Unit]
Description=Restore iptables rules
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
ExecReload=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Guarda el archivo y cárgalo en systemd:

sh
Copiar código
sudo systemctl daemon-reload
sudo systemctl enable iptables-restore.service
sudo systemctl start iptables-restore.service
Paso 4: Verificar la Conectividad
Después de hacer estas configuraciones, asegúrate de que las reglas de iptables se apliquen correctamente al reiniciar el servidor y verifica la conectividad entre las máquinas virtuales en las redes NAT y la red bridge utilizando herramientas como ping.

Verificar la Conexión
En la VM freeipa1 en nat_network_02:

sh
Copiar código
ping 192.168.0.35
Este comando debería hacer ping a la IP del nodo bastión bastion1 en la red bridge br0.

Siguiendo estos pasos, deberías tener configurada la comunicación entre tus redes NAT y la red bridge en tu entorno KVM.



Para solucionar el problema de permisos y guardar las reglas de iptables de manera persistente, puedes utilizar el comando sudo con tee para redirigir la salida. Aquí están los pasos detallados:

Paso 1: Guardar las Reglas de iptables
Utiliza el comando iptables-save junto con tee para guardar las reglas de iptables en el archivo /etc/iptables/rules.v4:

sh
Copiar código
sudo iptables-save | sudo tee /etc/iptables/rules.v4
Paso 2: Verificar que las Reglas se Guardaron Correctamente
Para asegurarte de que las reglas se guardaron correctamente, puedes visualizar el contenido del archivo:

sh
Copiar código
sudo cat /etc/iptables/rules.v4
Paso 3: Configurar el Sistema para Restaurar las Reglas en el Inicio
Para que las reglas de iptables se restauren automáticamente al reiniciar el sistema, puedes utilizar un script de inicio o crear un servicio de systemd. A continuación se muestran ambos métodos:

Opción A: Usar un Script de Inicio
Crea un script de inicio en /etc/network/if-pre-up.d/iptables:

sh
Copiar código
sudo nano /etc/network/if-pre-up.d/iptables
Añade las siguientes líneas al script:

sh
Copiar código
#!/bin/sh
/sbin/iptables-restore < /etc/iptables/rules.v4
Guarda el archivo y hazlo ejecutable:

sh
Copiar código
sudo chmod +x /etc/network/if-pre-up.d/iptables
Opción B: Usar un Servicio de systemd
Crea un archivo de servicio para iptables en /etc/systemd/system/iptables-restore.service:

sh
Copiar código
sudo nano /etc/systemd/system/iptables-restore.service
Añade las siguientes líneas al archivo del servicio:

ini
Copiar código
[Unit]
Description=Restore iptables rules
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore /etc/iptables/rules.v4
ExecReload=/sbin/iptables-restore /etc/iptables/rules.v4
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Guarda el archivo y recarga systemd para que reconozca el nuevo servicio:

sh
Copiar código
sudo systemctl daemon-reload
Habilita y inicia el servicio para que se ejecute automáticamente al inicio:

sh
Copiar código
sudo systemctl enable iptables-restore.service
sudo systemctl start iptables-restore.service
Paso 4: Configurar Rutas Estáticas en las Máquinas Virtuales
Para asegurar que las máquinas virtuales puedan comunicarse a través de las diferentes redes NAT y la red puente, agrega rutas estáticas en las máquinas virtuales:

En las VMs de nat_network_02:
sh
Copiar código
sudo ip route add 192.168.0.0/24 via 10.17.3.1
En las VMs de nat_network_03:
sh

Copiar código

sudo ip route add 192.168.0.0/24 via 10.17.4.1.

Paso 5: Verificar la Conectividad
Finalmente, verifica la conectividad entre las máquinas virtuales en las redes NAT y la red puente mediante ping o cualquier otra herramienta de red:

sh
Copiar código
ping 192.168.0.35  # Desde una VM en nat_network_02 o nat_network_03
Siguiendo estos pasos, deberías tener configurada la comunicación entre las redes NAT y la red puente (bridge) en tu entorno KVM.



Las interfaces br0, virbr0, y virbr1 que estás utilizando en tus reglas de iptables son correctas y están presentes en tu sistema según las salidas de los comandos ip link show y brctl show. Aquí te dejo un resumen de lo que has verificado y configurado:

Verificación de Interfaces
Puente br0:

Interfaces: enp3s0f0, vnet0
Puente virbr0:

Interfaces: vnet1, vnet2, vnet3
Puente virbr1:

Interfaces: vnet4, vnet5, vnet6, vnet7, vnet8, vnet9, vnet10
Reglas de iptables
Las reglas de iptables configuradas para permitir la comunicación entre las redes NAT (virbr0 y virbr1) y la red puente (br0) son:

sh
Copiar código
# Configuración para nat_network_02
sudo iptables -t nat -A POSTROUTING -s 10.17.3.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT

# Configuración para nat_network_03
sudo iptables -t nat -A POSTROUTING -s 10.17.4.0/24 -o br0 -j MASQUERADE
sudo iptables -A FORWARD -i br0 -o virbr1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i virbr1 -o br0 -j ACCEPT
Estas reglas están diseñadas para permitir que el tráfico fluya entre las interfaces de red virtual y el puente br0.

Verificación de las Reglas
Para verificar si las reglas se han aplicado correctamente y están funcionando, puedes utilizar los siguientes comandos:

Listar las reglas de iptables:

sh
Copiar código
sudo iptables -t nat -L
sudo iptables -L
Asegúrate de que las reglas que has añadido están presentes en la salida.

Persistencia de las Reglas
Si quieres asegurarte de que las reglas de iptables persistan después de reiniciar, asegúrate de guardar la configuración actual de iptables en un archivo de reglas persistentes. Esto ya lo has hecho con el siguiente comando:

sh
Copiar código
sudo iptables-save > /etc/iptables/rules.v4
Y configurando el sistema para restaurar estas reglas al inicio. En sistemas basados en Red Hat (como Rocky Linux), puedes crear un servicio systemd para restaurar las reglas:

Crear un servicio systemd:

Crea un archivo de servicio en /etc/systemd/system/iptables-restore.service:

sh
Copiar código
sudo nano /etc/systemd/system/iptables-restore.service
Añade el siguiente contenido:

ini
Copiar código
[Unit]
Description=Restaurar reglas de iptables
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore < /etc/iptables/rules.v4
ExecStart=/sbin/ip6tables-restore < /etc/iptables/rules.v6
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Habilitar y arrancar el servicio:

sh
Copiar código
sudo systemctl enable iptables-restore
sudo systemctl start iptables-restore
Resumen
Verificaste las interfaces de red:

br0, virbr0, y virbr1 están presentes y configuradas correctamente.
Configuraste las reglas de iptables:

Añadiste reglas para permitir el tráfico entre las redes NAT y el puente br0.
Persistencia de las reglas:

Guardaste las reglas en /etc/iptables/rules.v4.
Configuraste un servicio systemd para restaurar las reglas al inicio.
Con estos pasos, deberías tener una configuración funcional que permite la comunicación entre tus redes NAT y la red puente en tu entorno KVM.





