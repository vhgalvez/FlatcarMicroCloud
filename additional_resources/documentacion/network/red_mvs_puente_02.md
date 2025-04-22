¡Hola! ¡Absolutamente! Aquí tienes un texto que documenta todo lo que hemos realizado para configurar el balanceador de carga de la API de Kubernetes (k8s-api-lb) en tu red LAN, utilizando un switch virtual con bridge y Ansible para la automatización.

Documentación: Configuración del Balanceador de Carga de la API de Kubernetes en Red LAN con Switch Virtual (Bridge) y Ansible

Fecha: 22 de abril de 2025
Ubicación: Madrid, España
Autor: (Tu Nombre/Usuario)

Objetivo:

Documentar el proceso completo para configurar un balanceador de carga de alta disponibilidad para la API de Kubernetes (k8s-api-lb) en la red local (LAN) utilizando un switch virtual con bridge en el host Rocky Linux, y automatizar la configuración de HAProxy y Keepalived mediante Ansible. El objetivo principal de esta configuración es eliminar problemas de doble NAT y facilitar la comunicación directa con la API de Kubernetes desde la red LAN.

Entorno:

Sistema Operativo Host: Rocky Linux (donde se ejecuta Libvirt)
Virtualización: Libvirt
Herramienta de Gestión de Red en Host: NetworkManager (nmcli)
Infraestructura como Código: Terraform (para la creación de la red bridge)
Automatización de Configuración: Ansible
Balanceador de Carga: HAProxy
Alta Disponibilidad: Keepalived
Red LAN: 192.168.0.0/24
Red NAT para Nodos Kubernetes: 10.17.4.0/24
Dirección IP del Host Rocky Linux: (Asumir una IP en la LAN)
Dirección IP de la VM k8s-api-lb: 192.168.0.50 (en la LAN)
Dirección IP Virtual (VIP) para la API de Kubernetes: 192.168.0.55 (en la LAN)
Nodos Master de Kubernetes: 10.17.4.21, 10.17.4.22, 10.17.4.23 (en red NAT)
Pasos Realizados:

1. Configuración del Switch Virtual con Bridge en el Host (Rocky Linux) con Terraform:

Objetivo: Integrar directamente la VM k8s-api-lb a la red LAN (192.168.0.0/24) eliminando la necesidad de NAT para esta VM.
Proceso: Se modificó la definición de la red Libvirt kube_network_01 en los archivos Terraform para utilizar el modo bridge y conectarse a un puente (br0) creado en el sistema operativo host.
Pasos Detallados (según la documentación anterior):
Creación de la interfaz de puente br0 utilizando nmcli.
Asociación de la interfaz de red física del host a br0 como un esclavo.
Desactivación de la configuración IP en la interfaz física.
Activación de la interfaz del puente br0.
Modificación del recurso libvirt_network en Terraform para kube_network_01 estableciendo mode = "bridge" y bridge = "br0", y eliminando la definición de addresses.
Aplicación de los cambios con terraform apply.
Resultado: La VM k8s-api-lb conectada a kube_network_01 ahora obtiene una dirección IP directamente de la red LAN (192.168.0.50).
2. Configuración de Ansible para HAProxy y Keepalived:

Objetivo: Automatizar la instalación y configuración de HAProxy (como balanceador de carga) y Keepalived (para alta disponibilidad de la IP virtual) en la VM k8s-api-lb (192.168.0.50).
Inventario de Ansible (inventory): Se actualizó el archivo de inventario para reflejar la dirección IP de k8s-api-lb y se definió la nueva IP virtual (api_vip=192.168.0.55) en la sección [all:vars]. También se definieron los grupos para los nodos master y worker.
Playbook de Ansible (install_haproxy_keepalived.yml): Se realizaron las siguientes modificaciones:
Se actualizó la variable api_vip a "192.168.0.55".
Se mantuvo la lógica para obtener la interfaz activa para Keepalived (con la posibilidad de especificar br0 directamente si es consistente).
Se utilizaron plantillas Jinja (keepalived.conf.j2 y haproxy.cfg.j2) para generar los archivos de configuración.
Plantilla de Configuración de Keepalived (templates\keepalived\keepalived.conf.j2):
Se modificó la interface a br0.
Se actualizó la virtual_ipaddress a 192.168.0.55 en ambos bloques vrrp_instance (VI_1 y VI_2).
Plantilla de Configuración de HAProxy (templates\haproxy\haproxy.cfg.j2):
Se modificó la línea bind {{ api_vip }}:6443 en el frontend kubernetes_api a bind 192.168.0.55:6443.
Ejecución del Playbook: Se ejecutó el playbook de Ansible para aplicar la configuración al host 192.168.0.50.
Resultado: La VM k8s-api-lb ahora tiene HAProxy escuchando en la IP virtual 192.168.0.55:6443 y Keepalived gestionando la asignación de esta IP a la interfaz br0.
Motivación Detrás de la Implementación:

Corrección de la Doble NAT: La configuración inicial podría haber involucrado una doble NAT si la k8s-api-lb hubiera permanecido en una red NAT separada y tuviera que comunicarse con los nodos en otra red NAT. Esto puede causar problemas de conectividad, enrutamiento complejo y dificultades en el diagnóstico. El modo bridge elimina la NAT para la k8s-api-lb, simplificando la comunicación con la LAN.
Acceso Directo a la API: Al tener la IP virtual en la red LAN, los clientes (como kubectl ejecutándose en máquinas de la LAN) pueden acceder directamente a la API de Kubernetes a través de 192.168.0.55:6443 sin necesidad de reenvío de puertos.
Alta Disponibilidad: Keepalived asegura que la IP virtual esté siempre disponible, incluso si el nodo principal del balanceador de carga falla (en una configuración con múltiples balanceadores).
Próximos Pasos (Verificación):

Verificar que la IP virtual 192.168.0.55 esté activa en la interfaz br0 de la VM 192.168.0.50 (ip a).
Verificar que HAProxy esté escuchando en 192.168.0.55:6443 (netstat -tulnp | grep 6443).
Verificar el estado de los servicios haproxy y keepalived (systemctl status haproxy, systemctl status keepalived).
Intentar acceder a la API de Kubernetes desde una máquina en la LAN utilizando kubectl configurado para apuntar a https://192.168.0.55:6443.
Conclusión:

Se ha configurado exitosamente un balanceador de carga de alta disponibilidad para la API de Kubernetes en la red LAN utilizando un switch virtual con bridge y Ansible para la automatización. Esta configuración resuelve problemas de doble NAT, simplifica el acceso a la API y proporciona alta disponibilidad.

Espero que esta documentación sea clara y te ayude a replicar y entender todo lo que hemos realizado. ¡No dudes en preguntar si tienes alguna otra duda!



[victory@virtualizacion-server ansible-CoreDNS-setup-Linux]$ sudo virsh net-list --all
[sudo] password for victory:
 Nombre            Estado   Inicio automático   Persistente
-------------------------------------------------------------
 default           activo   si                  si
 kube_network_01   activo   si                  si
 kube_network_02   activo   si                  si
 kube_network_03   activo   si                  si

[victory@virtualizacion-server ansible-CoreDNS-setup-Linux]$ sudo virsh net-dumpxml kube_network_01
<network connections='1'>
  <name>kube_network_01</name>
  <uuid>ef95b3eb-1894-4037-ae14-28b860c1ffd3</uuid>
  <forward mode='bridge'/>
  <bridge name='br0'/>
</network>

[victory@virtualizacion-server ansible-CoreDNS-setup-Linux]$ sudo virsh net-dumpxml kube_network_02
<network connections='4'>
  <name>kube_network_02</name>
  <uuid>04a26109-95ab-4774-b4ba-fe4b34e5062b</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr_kube02' stp='on' delay='0'/>
  <mac address='52:54:00:ac:d2:81'/>
  <domain name='kube.internal'/>
  <ip family='ipv4' address='10.17.3.1' prefix='24'>
    <dhcp>
      <range start='10.17.3.2' end='10.17.3.254'/>
      <host mac='52:54:00:fa:a1:a0' name='load_balancer2' ip='10.17.3.13'/>
      <host mac='52:54:00:3a:00:ae' name='load_balancer1' ip='10.17.3.12'/>
      <host mac='52:54:00:ce:eb:e6' name='postgresql1' ip='10.17.3.14'/>
      <host mac='52:54:00:12:35:8e' name='infra-cluster' ip='10.17.3.11'/>
    </dhcp>
  </ip>
</network>

[victory@virtualizacion-server ansible-CoreDNS-setup-Linux]$ sudo virsh net-dumpxml kube_network_03
<network connections='2'>
  <name>kube_network_03</name>
  <uuid>581caddf-b500-49f0-b758-0a21e033751d</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr_kube03' stp='on' delay='0'/>
  <mac address='52:54:00:04:40:c6'/>
  <domain name='kube.internal'/>
  <ip family='ipv4' address='10.17.4.1' prefix='24'>
    <dhcp>
      <range start='10.17.4.2' end='10.17.4.254'/>
      <host mac='52:54:00:e6:72:62' name='master3' ip='10.17.4.23'/>
      <host mac='52:54:00:0a:f3:77' name='master2' ip='10.17.4.22'/>
      <host mac='52:54:00:da:fe:c8' name='worker3' ip='10.17.4.26'/>
      <host mac='52:54:00:96:a9:cb' name='worker1' ip='10.17.4.24'/>
      <host mac='52:54:00:8e:01:97' name='worker2' ip='10.17.4.25'/>
      <host mac='52:54:00:c6:ba:3c' name='master1' ip='10.17.4.21'/>
      <host mac='52:54:00:12:fe:92' name='storage1' ip='10.17.4.27'/>
    </dhcp>
  </ip>
</network>

[victory@virtualizacion-server ansible-CoreDNS-setup-Linux]$
