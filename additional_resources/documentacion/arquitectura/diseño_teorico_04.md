                           [Usuarios Públicos]
                                   |
                         +--------------------+
                         |    Cloudflare CDN  |
                         |  (Proxy y Cache)   |
                         +--------------------+
                                   |
                        HTTPS (80/443) Traffic
                                   |
                         +--------------------+
                         |     VPS (VPN)      |
                         |  IP Pública: XXX.X.X.X |
                         +--------------------+
                           |              |
                           |              |---> [Teletrabajadores] 
                           |                     WireGuard VPN  
                           |
            +==================== WireGuard VPN Tunnel ====================+
            |                                                              |
    +--------------------+                                    +--------------------------+
    | Servidor Físico    |                                    | Red LAN Local            |
    | IP: 192.168.0.X    |                                    | Subred: 192.168.0.0/24   |
    | (Puente br0)       |                                    | Gateway: 192.168.0.1     |
    +--------------------+                                    +--------------------------+
            |                                                              |
            |                                                              |
    +--------------------+                                    +--------------------------+
    | Redes NAT para     |                                    | Microservicios          |
    | Máquinas Virtuales |                                    | (Traefik Ingress)       |
    | 10.17.3.0/24       |                                    | HTTPS Público (80/443)  |
    | 10.17.4.0/24       |                                    +--------------------------+
    +--------------------+                                           |
            |                                                       |
    +--------------------+                                    +--------------------------+
    | Redes Internas     |                                    | Contenedores (Podman)    |
    | Subred Podman      |                                    | Red: 10.89.0.0/24       |
    | 10.89.0.0/24       |                                    +--------------------------+
    +--------------------+

                                   DESGLOSE DE COMPONENTES:

    [VPS]
    - Servidor con IP pública para exposición al Internet.
    - Puerta de enlace VPN (WireGuard) para cifrar tráfico entre usuarios y el servidor físico.
    - Permite acceso remoto seguro desde teletrabajadores a recursos internos del servidor físico.

    [Servidor Físico]
    - Configuración de puente (br0) para acceso directo a Internet de las máquinas virtuales (VMs).
    - Redes NAT:
      - kube_network_02: 10.17.3.0/24 (Servicios administrativos y balanceadores).
      - kube_network_03: 10.17.4.0/24 (Nodos Kubernetes y almacenamiento).
    - Túnel VPN con el VPS para acceso seguro.

    [Red Interna Local (LAN)]
    - Red privada (192.168.0.0/24) utilizada para la gestión y administración interna.
    - Conectada al túnel VPN para permitir comunicación entre recursos internos y externos.

    [Microservicios]
    - Controlador Ingress Traefik para manejar tráfico HTTPS hacia aplicaciones expuestas.
    - Balanceadores en las redes 10.17.3.0/24 y 10.17.4.0/24 para distribuir carga entre servicios.

    [Teletrabajadores]
    - Acceso seguro a través del túnel VPN establecido en el VPS.
    - Posibilidad de conectarse a los recursos internos del servidor físico (red LAN y máquinas virtuales).
