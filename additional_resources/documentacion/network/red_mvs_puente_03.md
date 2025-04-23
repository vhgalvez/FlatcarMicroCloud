Documento: Solución de Problemas de Conectividad en FlatcarMicroCloud mediante Open vSwitch y Configuración de Red Bridge

Fecha: 23 de abril de 2025
Ubicación: Madrid, España
Autor: (Tu Nombre/Usuario)

1. Identificación del Problema:

Se detectaron problemas de conectividad significativos en el entorno FlatcarMicroCloud, específicamente desde los nodos master de Kubernetes (10.17.4.0/24). Estos problemas se manifestaron como la incapacidad de alcanzar varios recursos y servicios esenciales:

192.168.0.50 (k8s-api-lb): Pérdida total de paquetes, lo que impedía la comunicación con el balanceador de carga de la API de Kubernetes.
10.17.3.11 (freeipa1): Fallo con error "Destination Port Unreachable", indicando un problema de enrutamiento o firewall hacia el servidor DNS y de autenticación.
192.168.0.1 (router LAN): Pérdida total de paquetes, lo que aislaba los nodos de la red local.
8.8.8.8 (DNS público): Pérdida total de paquetes, impidiendo la resolución de nombres externa y el acceso a Internet.
192.168.0.55 (IP virtual de la API): Pérdida total de paquetes, lo que dificultaba el acceso a la API de Kubernetes a través del balanceador de carga.
Estos problemas de conectividad apuntaban a una configuración de red subyacente que no permitía el tráfico adecuado entre las diferentes redes virtuales gestionadas por Libvirt y la red local (LAN). La configuración inicial utilizaba el modo NAT para las redes virtuales, lo que introducía complejidad en el enrutamiento y posibles problemas de doble NAT.

2. Solicitud de Solución:

La solicitud era establecer una comunicación fluida y directa entre los diferentes componentes del entorno FlatcarMicroCloud, incluyendo los nodos Kubernetes, el balanceador de carga de la API, el servidor DNS/autenticación y la red local. El objetivo principal era eliminar los problemas de conectividad que impedían la correcta operación del clúster Kubernetes y otros servicios.

3. Solución Implementada: Configuración de Red Bridge con Open vSwitch:

Para solucionar los problemas de conectividad, se implementó la siguiente estrategia utilizando Open vSwitch (OVS) para gestionar las redes virtuales y facilitar la comunicación a nivel de capa 2:

3.1. Instalación de Open vSwitch:

En el sistema host (Rocky Linux), se instaló Open vSwitch y sus servicios:

Bash

sudo dnf install openvswitch openvswitch-services
sudo systemctl enable --now openvswitch-services
sudo systemctl status openvswitch-services
3.2. Reconfiguración de las Redes Libvirt en Modo Bridge:

Se modificaron los archivos de configuración de Terraform para las redes Libvirt involucradas (br0, kube_network_02, kube_network_03) para utilizar el modo bridge y conectarse a un puente OVS (br0 existente):

br0_network/main.tf:

Terraform

resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  # addresses = ["10.17.5.0/24"] # Eliminado o comentado
}
nat_network_02/main.tf:

Terraform

resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  # addresses = ["10.17.3.0/24"] # Eliminado o comentado
}
nat_network_03/main.tf:

Terraform

resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  # addresses = ["10.17.4.0/24"] # Eliminado o comentado
}
Se aplicaron los cambios con terraform apply en cada directorio.

3.3. Configuración del Puente OVS (br0):

Se hizo que Open vSwitch gestionara el puente br0 existente y se conectó la interfaz física del host a este puente:

Bash

sudo ovs-vsctl add-port br0 <nombre_de_la_interfaz_fisica>
sudo ip addr flush dev <nombre_de_la_interfaz_fisica>
sudo systemctl restart NetworkManager
Se verificó y/o configuró la dirección IP del puente br0 para asegurar la conectividad con la LAN.

3.4. Configuración de nftables (Firewall):

Se modificaron las reglas de nftables en el host para permitir el tráfico entre las redes bridge y la LAN:

Fragmento de código

#!/usr/sbin/nft -f

flush ruleset

# 👮 Tabla de filtrado
table inet filter {
    chain input {
        type filter hook input priority 0; policy accept;

        # ... (reglas de entrada existentes) ...
        iifname { "virbr0", "virbr_kube01", "virbr_kube02", "virbr_kube03", "br0" } accept
        drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        # ✅ Permitir tráfico entre todas las subredes internas (10.17.0.0/16)
        ip saddr 10.17.0.0/16 ip daddr 10.17.0.0/16 accept

        # ✅ Permitir tráfico entre la LAN (192.168.0.0/24) y las subredes internas
        ip saddr 192.168.0.0/24 ip daddr 10.17.0.0/16 accept
        ip saddr 10.17.0.0/16 ip daddr 192.168.0.0/24 accept

        # ✅ Permitir tráfico que pasa por el puente br0
        bridge iifname "br0" accept
        bridge oifname "br0" accept

        # ... (otras reglas de forward existentes) ...
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# 🔄 Tabla de NAT
table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;

        # ... (reglas de masquerade existentes) ...
    }
}
Se aplicaron las nuevas reglas con sudo nft -f /etc/nftables/flatcar-microcloud.conf y se habilitó el servicio nftables.

4. Resultado de la Solución:

Después de implementar la configuración de red bridge con Open vSwitch y ajustar las reglas del firewall, se espera que los problemas de conectividad iniciales se resuelvan. Los nodos master de Kubernetes (10.17.4.0/24) deberían ahora poder comunicarse directamente con:

192.168.0.50 (k8s-api-lb): Ya que todas las redes están en el mismo segmento de capa 2 (el puente br0).
10.17.3.11 (freeipa1): De manera similar, la comunicación directa debería ser posible.
192.168.0.1 (router LAN): La conectividad con la LAN se establece a través del puente br0.
8.8.8.8 (DNS público): El tráfico ahora debería poder salir a Internet a través de la interfaz física conectada al puente br0, sujeto a las reglas de NAT en nftables.
192.168.0.55 (IP virtual de la API): La comunicación con la VIP en la LAN debería ser directa.
5. Documentación del Error Original:

El error original radicaba en la configuración de las redes virtuales en modo NAT, lo que creaba barreras de comunicación y requería un enrutamiento complejo que no estaba configurado correctamente. El "Destination Port Unreachable" al intentar hacer ping a freeipa1 era un síntoma de este problema de enrutamiento a nivel del gateway NAT de la red 10.17.4.0/24. La falta de conectividad con la LAN y el exterior también era una consecuencia de esta configuración aislada y la falta de reglas de reenvío adecuadas.

6. Conclusión:

La transición al modo de red bridge utilizando Open vSwitch proporciona una arquitectura de red más plana y directa para el entorno FlatcarMicroCloud. Al conectar todas las redes virtuales relevantes al mismo puente (br0), se elimina la necesidad de NAT para la comunicación interna y con la LAN. La correcta configuración del puente OVS y las reglas de firewall en el host son cruciales para asegurar que el tráfico se reenvíe correctamente y que se restablezca la conectividad entre todos los componentes del entorno. Se recomienda verificar la conectividad después de aplicar esta configuración realizando nuevamente las pruebas de ping desde los nodos master.



Documento: Análisis de la Raíz del Problema de Conectividad en FlatcarMicroCloud (Pre-Implementación de Open vSwitch Bridge)

Fecha: 23 de abril de 2025
Ubicación: Rivas-Vaciamadrid, Comunidad de Madrid, España
Autor: (Tu Nombre/Usuario)

1. Descripción del Error Original:

El entorno FlatcarMicroCloud experimentaba problemas significativos de conectividad, evidenciados por la incapacidad de los nodos master de Kubernetes (10.17.4.0/24) para comunicarse con varios recursos esenciales. Los síntomas principales incluían:

Aislamiento de la red LAN (192.168.0.0/24): Los pings a direcciones IP en la LAN (incluyendo el gateway y el balanceador de carga de la API) fallaban consistentemente.
Inaccesibilidad al servidor DNS/Autenticación (10.17.3.11): Los intentos de comunicación resultaban en errores de "Destination Port Unreachable", lo que sugería un bloqueo a nivel de enrutamiento o firewall.
Falta de conectividad externa (Internet): Los pings a servidores DNS públicos fallaban, indicando que los nodos no podían alcanzar la red externa.
2. Análisis de la Configuración de Red Original:

La configuración de red inicial se basaba en el uso del modo Network Address Translation (NAT) para las redes virtuales gestionadas por Libvirt:

kube_network_02 (10.17.3.0/24): Aloja freeipa1, loadbalancer1, loadbalancer2, postgresql1. En modo NAT, Libvirt actuaba como un enrutador para esta red, traduciendo las direcciones IP internas de las VMs a la dirección IP del host para la comunicación externa.
kube_network_03 (10.17.4.0/24): Aloja los nodos master, worker y storage1. Similar a kube_network_02, Libvirt gestionaba el NAT para esta red.
br0 (10.17.5.0/24): Aloja k8s-api-lb. También configurada en modo NAT por Libvirt.
3. Identificación de la Raíz del Problema:

La raíz de los problemas de conectividad residía en la naturaleza aislada de las redes NAT y la falta de una configuración de enrutamiento explícita y bidireccional entre estas redes y la red LAN.

Aislamiento de Redes NAT: En el modo NAT, cada red virtual creada por Libvirt opera en su propio espacio de direcciones IP aislado. Por defecto, no existe una ruta automática para que el tráfico se mueva entre diferentes redes NAT gestionadas por Libvirt o entre una red NAT y la red física subyacente (LAN).

Falta de Enrutamiento: Para que la comunicación sea posible entre diferentes subredes IP (como 10.17.4.0/24 y 192.168.0.0/24 o 10.17.3.0/24), se deben configurar rutas explícitas a nivel del sistema host (donde se ejecuta Libvirt) o a través de un enrutador en la red física. En la configuración original, estas rutas no estaban adecuadamente establecidas.

"Destination Port Unreachable" a freeipa1: Este error específico sugiere que el tráfico desde la red 10.17.4.0/24 llegaba al gateway NAT de esa red (la interfaz virtual de Libvirt para kube_network_03, probablemente 10.17.4.1), pero este gateway no tenía una ruta definida para alcanzar la red 10.17.3.0/24 donde reside freeipa1, o el firewall en el gateway estaba bloqueando el tráfico.

Falta de Conectividad Externa: La comunicación con Internet (a través de 8.8.8.8) fallaba porque, aunque la tabla NAT de nftables estaba configurada para realizar masquerade del tráfico saliente desde las redes 10.17.x.x hacia la interfaz física del host, el tráfico originado en estas redes no estaba siendo correctamente enrutado hacia esa interfaz física para salir.

Problemas con la LAN: La incapacidad de alcanzar direcciones en la LAN (192.168.0.0/24) desde las redes 10.17.x.x se debía a la falta de rutas de reenvío configuradas en el host que permitieran el tráfico entre estos rangos de IP.

4. Conclusión sobre la Raíz del Problema:

La raíz de los problemas de conectividad en la configuración original de FlatcarMicroCloud residía en la dependencia del modo NAT para las redes virtuales sin la configuración de enrutamiento explícita necesaria para permitir la comunicación entre estas redes y la red LAN. El modo NAT, por su naturaleza, crea límites de red aislados, y superar estos límites requiere una configuración de enrutamiento y firewall adecuada a nivel del host o de un enrutador externo. La falta de esta configuración resultó en el aislamiento de los nodos Kubernetes y la incapacidad de comunicarse con servicios esenciales y la red externa.

La solución de implementar Open vSwitch en modo bridge aborda directamente esta raíz del problema al eliminar la capa de NAT para la comunicación interna y con la LAN, permitiendo una comunicación más directa a nivel de capa 2. Esto simplifica significativamente el enrutamiento y elimina la necesidad de complejas reglas de reenvío de puertos que son típicas en entornos con múltiples capas de NAT.


​Para instalar Open vSwitch en AlmaLinux 9.5, necesitas habilitar el repositorio del SIG de NFV de CentOS, ya que los paquetes no están disponibles por defecto. Sigue estos pasos:​

Habilita el repositorio NFV OpenvSwitch:

bash
Copiar
Editar
sudo dnf install -y centos-release-nfv-openvswitch
Instala Open vSwitch:

bash
Copiar
Editar
sudo dnf install -y openvswitch2.17
Nota: El paquete se llama openvswitch2.17 en este repositorio.

Habilita y arranca el servicio:

bash
Copiar
Editar
sudo systemctl enable --now openvswitch
Este procedimiento ha sido validado en entornos similares y se ha documentado en foros especializados. ​

Si prefieres compilar Open vSwitch desde el código fuente, puedes seguir las instrucciones oficiales proporcionadas por el proyecto. 
docs.openvswitch.org
​

¿Necesitas asistencia adicional para configurar puentes (br0) o integrar Open vSwitch con Libvirt?

sudo ovs-vsctl show