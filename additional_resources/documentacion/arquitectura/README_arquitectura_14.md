Resumen Completo de la Implementación en virtualizacion-server
1. Contexto del Servidor de Virtualización:

Tu servidor (virtualizacion-server) es un host de virtualización con 4 interfaces de red físicas (enp3s0f0, enp3s0f1, enp4s0f0, enp4s0f1).
Aloja múltiples máquinas virtuales (VMs) que necesitan conectividad entre sí y a Internet.
Las VMs se conectan a puentes virtuales (br0, virbr_kube02, virbr_kube03).
2. Problema Identificado (Hipótesis Principal):

Las máquinas virtuales conectadas a virbr_kube02 y virbr_kube03 (como infra-cluster y master1) carecen de acceso consistente a Internet (no pueden hacer ping a 192.168.0.1 ni a 8.8.8.8).

La Causa Raíz es el Conflicto de Enrutamiento en el Host:
Tu host está adquiriendo direcciones IP y, por ende, creando múltiples "rutas predeterminadas" (default routes) a través de varias de sus interfaces físicas (enp3s0f0, enp3s0f1, enp4s0f0), todas en la misma subred (192.168.0.0/24).
Específicamente, enp3s0f1 estaba obteniendo múltiples IPs dinámicas, lo que exacerbaba el problema.
Esta ambigüedad impide que el host determine de forma fiable por dónde enviar el tráfico de las VMs hacia Internet.
Diagnóstico Adicional: Las reglas de tu firewall (/etc/sysconfig/nftables.conf) fueron revisadas y confirmadas como correctas, incluyendo las reglas de reenvío y NAT para las VMs. Esto significa que el problema no reside en el firewall. La VM k8s-api-lb sí tiene acceso a Internet, lo que apoya la idea de un problema de enrutamiento del host más que de firewall global.
3. Solución Propuesta y Diseño de Red Final para el Host:

Para resolver el conflicto de enrutamiento y aprovechar tu hardware, implementaremos el siguiente diseño de red para el host:

Interfaz	IP del Host	Función / Red	Tipo de Configuración	Gateway	Observaciones Clave
enp3s0f0	192.168.0.40/24	LAN principal / Salida a Internet	Estática	192.168.0.1	Esta será la única interfaz del host con una ruta predeterminada. Maneja el tráfico saliente del host y el tráfico NAT de las VMs a Internet.
enp3s0f1	192.168.50.1/24	Red de Gestión Privada	Estática	❌ NINGUNO	Sin puerta de enlace. Dedicada para el acceso de administración seguro (SSH, etc.) al host, aislado de la red principal. Accederás al host vía 192.168.50.1 desde un dispositivo en esa red.
enp4s0f0	192.168.60.1/24	Red de Pruebas / WiFi	Estática	❌ NINGUNO	Sin puerta de enlace. Ideal para conectar un router Wi-Fi de pruebas o para experimentos de red aislados. El host tendrá conectividad directa a dispositivos en esta subred (192.168.60.x).
enp4s0f1	(sin IP)	Esclava de br0 (bridge)	Esclava de bridge	❌ NINGUNO	Parte del puente br0 para conectar VMs a la red principal. La interfaz física no tiene IP propia.