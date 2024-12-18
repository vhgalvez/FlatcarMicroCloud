Infraestructura de Red Final para Implementar pfSense con KVM/Libvirt y Kubernetes 🚀
Aquí tienes un resumen ordenado, optimizado y mejorado para tu red, con detalles adicionales y pasos concretos.

1. Estructura Física y Virtual
Redes Físicas
Las interfaces enp3s0f0 y enp3s0f1 del servidor físico serán configuradas como puentes:

Interfaz Física	Uso	Descripción
enp3s0f0	WAN	Tráfico externo (red pública).
enp3s0f1	LAN	Red interna principal.
Puentes Virtuales
Los puentes br0 y br1 conectarán las interfaces físicas con las máquinas virtuales.

Puente WAN (br0)
Asociado a enp3s0f0 para tráfico externo.

bash
Copy code
sudo nmcli connection add type bridge con-name br0 ifname br0
sudo nmcli connection add type bridge-slave con-name br0-enp3s0f0 ifname enp3s0f0 master br0
sudo nmcli connection modify br0 ipv4.addresses 192.168.0.10/24 ipv4.method manual
sudo nmcli connection up br0
Puente LAN (br1)
Asociado a enp3s0f1 para la red interna.

bash
Copy code
sudo nmcli connection add type bridge con-name br1 ifname br1
sudo nmcli connection add type bridge-slave con-name br1-enp3s0f1 ifname enp3s0f1 master br1
sudo nmcli connection modify br1 ipv4.addresses 192.168.1.1/24 ipv4.method manual
sudo nmcli connection up br1
2. Subredes Internas
Red	Rango IP	Descripción
Red LAN	192.168.0.0/24	Red interna física principal (LAN).
Cluster Interna	10.17.3.0/24	Servicios críticos (Traefik, DNS).
Cluster etcd	10.17.4.0/24	Nodos Masters y Workers.
Seguridad y gestión	10.17.5.0/24	Nodo Bastión para gestión segura.
VPN WireGuard	10.17.0.0/24	Seguridad y acceso remoto (VPN).
3. Configuración de Terraform
Redes Libvirt
Configura las redes WAN y LAN como puentes:

hcl
Copy code
# Red WAN (br0)
resource "libvirt_network" "wan" {
  name      = "wan_network"
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
}

# Red LAN (br1)
resource "libvirt_network" "lan" {
  name      = "lan_network"
  mode      = "bridge"
  bridge    = "br1"
  autostart = true
}
pfSense VM
La máquina virtual de pfSense se conectará a las redes WAN y LAN:

hcl
Copy code
resource "libvirt_domain" "pfsense" {
  name   = "pfsense-firewall"
  memory = 2048
  vcpu   = 2

  # Red WAN (br0)
  network_interface {
    network_id = libvirt_network.wan.id
    mac        = "52:54:00:11:22:33"
  }

  # Red LAN (br1)
  network_interface {
    network_id = libvirt_network.lan.id
    mac        = "52:54:00:44:55:66"
  }

  # Disco principal
  disk {
    volume_id = libvirt_volume.pfsense_disk.id
  }

  # Montar la ISO
  disk {
    volume_id = libvirt_volume.pfsense_iso.id
    scsi      = true
    readonly  = true
  }

  # Boot desde CD-ROM
  boot_device {
    dev = ["cdrom", "hd"]
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
4. Configuración de pfSense
Interfaces
WAN:
IP: 192.168.0.10/24 (conectada a br0).
Gateway: IP del router de la red externa.
LAN:
IP: 192.168.1.1/24 (puerta de enlace principal para la LAN).
Rutas Estáticas
Configura las siguientes rutas estáticas en pfSense:

10.17.0.0/24 → Para acceso a VPN WireGuard.
10.17.3.0/24 → Cluster interna.
10.17.4.0/24 → Cluster Kubernetes.
10.17.5.0/24 → Gestión segura.
5. VPN WireGuard
Implementa WireGuard en pfSense para asegurar acceso remoto:

Subred VPN: 10.17.0.0/24.
Gateway VPN: 10.17.0.1.
Permite rutas a las redes LAN y clústeres.
6. Flujo de Red Final
Diagrama General
plaintext
Copy code
Usuarios Públicos --> Cloudflare CDN --> pfSense WAN (br0) --> Servicios Internos

                               +--------------------+
                               |  pfSense Firewall  |
                               |  WAN: 192.168.0.10 |
                               |  LAN: 192.168.1.1  |
                               +--------------------+
                                       | LAN (br1)
                                       v
        +-----------------------+-----------------------+-----------------------+
        |                       |                       |                       |
        v                       v                       v                       v
+---------------+    +------------------+    +------------------+    +------------------+
| Bastion Node  |    | FreeIPA Node     |    | PostgreSQL Node  |    | Worker Node 1    |
| 10.17.5.2     |    | 10.17.3.11       |    | 10.17.3.14       |    | 10.17.4.24       |
+---------------+    +------------------+    +------------------+    +------------------+
Conclusión
Tu infraestructura está ahora bien organizada y lista para implementar pfSense como firewall/gateway en una máquina virtual con KVM. Además:

Los puentes br0 y br1 permiten tráfico externo e interno.
pfSense enruta y asegura todas las redes internas y externas.
WireGuard garantiza un acceso remoto seguro.
Este diseño es robusto, seguro y escalable para proyectos Kubernetes y otros servicios críticos.