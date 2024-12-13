Proyecto de Conectividad: Configuración de Redes Integradas con Adaptador Puente
Resumen del Proyecto
Este proyecto busca consolidar y optimizar la infraestructura de red en un servidor físico que opera varias máquinas virtuales (MVs), contenedores y una red VPN. El objetivo es utilizar un único adaptador puente (br0) para la conectividad general, asegurando acceso a Internet, comunicación entre redes internas (NAT) y soporte para VPN y contenedores.

La configuración incluye:

Adaptador Puente (br0): Conecta las MVs al adaptador físico para acceso a Internet.
Red NAT para MVs: Redes privadas 10.17.3.xx y 10.17.4.xx para los servicios internos.
VPN (WireGuard): Para acceso seguro remoto y salida hacia Internet.
Red de Contenedores (podman1): Proporciona una red aislada para los contenedores que también se conecta a través de br0.
Arquitectura General
Componentes Principales:
IP Pública del VPS: A través de WireGuard, conecta el servidor físico a una red pública segura.
Servidor Físico: Alberga las MVs, redes NAT y contenedores.
Red VPN: Ofrece acceso remoto seguro y salida de tráfico interno.
Red NAT:
kube_network_02: Red privada 10.17.3.0/24 para nodos administrativos.
kube_network_03: Red privada 10.17.4.0/24 para nodos de Kubernetes.
Contenedores (podman1): Red aislada 10.89.0.0/24 para aplicaciones.
Detalles de Configuración
Adaptador Puente (br0)
Proporciona conectividad entre el servidor físico, las MVs y las redes internas.
Dirección IP: 192.168.0.200/24.
Conectado al router principal para acceso a Internet.
Red NAT para MVs
kube_network_02:
Rango IP: 10.17.3.0/24.
Uso: Nodos administrativos y balanceadores de carga.
kube_network_03:
Rango IP: 10.17.4.0/24.
Uso: Nodos Kubernetes y almacenamiento.
Red VPN (WireGuard)
Conecta el servidor físico a un VPS con IP pública.
Proporciona acceso remoto seguro y oculta las redes internas.
Rango IP VPN: 10.17.0.0/24.
Red de Contenedores (podman1)
Rango IP: 10.89.0.0/24.
Red aislada para contenedores gestionados con Podman.
Configuración del Firewall con nftables
Tabla de Filtros (inet filter)
nft
Copy code
table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        ct state established,related accept; # Permitir conexiones establecidas
        iifname "lo" accept;                 # Permitir tráfico en el loopback
        iifname "br0" accept;               # Permitir tráfico en el adaptador puente
        udp dport 51820 accept;             # Permitir tráfico WireGuard (VPN)
        tcp dport {80, 443} accept;         # Permitir tráfico HTTPS
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        # Permitir tráfico entre redes internas (NAT y puente)
        ip saddr 10.17.3.0/24 ip daddr 192.168.0.0/24 accept;
        ip saddr 10.17.4.0/24 ip daddr 192.168.0.0/24 accept;
        ip saddr 192.168.0.0/24 ip daddr 10.17.3.0/24 accept;
        ip saddr 192.168.0.0/24 ip daddr 10.17.4.0/24 accept;
        ip saddr 10.17.0.0/24 ip daddr 10.17.3.0/24 accept;
        ip saddr 10.17.0.0/24 ip daddr 10.17.4.0/24 accept;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
Tabla de NAT (ip nat)
nft
Copy code
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        # Masquerade para tráfico saliente de las redes internas a través de la VPN
        ip saddr 10.17.3.0/24 oifname "wg0" masquerade;
        ip saddr 10.17.4.0/24 oifname "wg0" masquerade;
        ip saddr 192.168.0.0/24 oifname "wg0" masquerade;
    }
}
Configuración de Redes Virtuales con libvirt
Red br0
hcl
Copy code
resource "libvirt_network" "br0" {
  name      = "br0"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
}
Red kube_network_02
hcl
Copy code
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}
Red kube_network_03
hcl
Copy code
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
Resultados Esperados
Conectividad:

Las MVs tendrán acceso a Internet a través de br0.
Las redes NAT (10.17.3.0/24 y 10.17.4.0/24) estarán completamente aisladas del exterior, excepto a través de la VPN.
Seguridad:

El firewall controla estrictamente el tráfico interno y externo.
La VPN asegura acceso remoto y oculta las redes privadas.
Escalabilidad:

Es posible añadir nuevas MVs, contenedores y servicios sin modificar la arquitectura base.
Eficiencia Operativa:

Las redes NAT y puente están optimizadas para evitar solapamiento y garantizar un enrutamiento claro.
Si necesitas más detalles o ajustes específicos, puedo ayudarte a afinar cualquier componente.