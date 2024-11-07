# Terraform configuration for a libvirt domain with a network interface

Configurar NetworkManager para Ignorar Interfaces Manejadas por Terraform:

Ajusta NetworkManager para que ignore las interfaces que Terraform va a manejar. Esto puede hacerse configurando el archivo /etc/NetworkManager/NetworkManager.conf para especificar unmanaged-devices por sus nombres de dispositivo o patrones.
Por ejemplo, puedes añadir una línea como esta en el archivo de configuración de NetworkManager para excluir la interfaz de puente y las interfaces Ethernet vinculadas:
plaintext
Copy code
[keyfile]
unmanaged-devices=interface-name:br0;interface-name:enp3s0f0
Revisar y Ajustar el Código de Terraform:

Asegúrate de que la configuración de Terraform para el puente (libvirt_network) y las máquinas virtuales (libvirt_domain) esté completa y correcta.
Verifica que las definiciones de red en las máquinas virtuales (a través de cloud-init) no asignen IPs estáticas que podrían causar conflictos dentro de la misma subred o con el host.
Aplicar Configuración de Terraform:

Ejecuta terraform init para inicializar el entorno y luego terraform plan para ver qué cambios aplicará Terraform. Esto te dará una buena visión de las acciones que Terraform realizará y si hay algo que necesite ajustes antes de aplicar los cambios.
Ejecuta terraform apply para aplicar los cambios. Esto debería configurar toda la red y las máquinas virtuales según lo definido en tus archivos .tf.
Verificar la Configuración Post-Terraform:

Verifica que todas las interfaces y puentes estén configurados como se esperaba usando comandos como ip addr y brctl show.
Asegúrate de que las máquinas virtuales pueden comunicarse entre sí y con el exterior conforme a la configuración de red aplicada.
Monitoreo y Logs:

Monitorea los logs de libvirt, NetworkManager, y los sistemas de las VM para asegurar que no hay errores inesperados y que la red funciona como se espera.
Al seguir estos pasos, podrás tener una configuración más limpia y mantenible, con Terraform gestionando toda la infraestructura virtual sin interferencias de configuraciones manuales previas.