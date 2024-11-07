# Proceso de Configuración del Clúster OpenShift

## 1. Preparación del Entorno

   1. **Verificación de Hardware**:
   
      - Confirmar compatibilidad del hardware con KVM y libvirt
  
      - Para confirmar si tu hardware es compatible con KVM y si puedes utilizar libvirt
         para gestionar máquinas virtuales en Rocky Linux 9.3 (Blue Onyx), puedes seguir estos pasos:

         - Antes de todo, asegúrate de que tu CPU soporte la virtualización. Los procesadores Intel deben tener habilitadas las tecnologías VT-x (para Intel) y VT-d (si quieres usar dispositivos de entrada/salida virtualizados), mientras que en AMD debes buscar soporte para AMD-V.

            **Comando para verificar:**
            Abre una terminal y ejecuta el siguiente comando para ver si tu CPU soporta KVM:

            ```bash
            egrep -c '(vmx|svm)' /proc/cpuinfo
            ```

            ```bash
            [victory@server ~]$ egrep -c '(vmx|svm)' /proc/cpuinfo
            48
            ```

         El comando `egrep -c '(vmx|svm)' /proc/cpuinfo` busca en la información del procesador las extensiones de virtualización:

         - `vmx`: Tecnología de virtualización VT-x de Intel.
         - `svm`: Tecnología de virtualización AMD-V de AMD.

   El número `48` indica que hay 48 núcleos o hilos en el procesador que soportan estas tecnologías de virtualización.

 **Conclusión**: Este resultado positivo confirma que el hardware de tu servidor es compatible con virtualización a nivel de hardware, lo cual es crucial para el uso eficiente de KVM (Kernel-based Virtual Machine)

   2. **Instalación de KVM y Libvirt**:
   
      - Instalar y configurar KVM y libvirt en Rocky Linux para la gestión de la virtualización.

         - `dnf install qemu-kvm libvirt virt-manager virt-install`: Instala los paquetes necesarios para la virtualización de KVM, incluyendo el hipervisor QEMU-KVM, la biblioteca libvirt, virt-manager y virt-install.

         - `dnf install epel-release -y`: Instala el repositorio Extra Packages for Enterprise Linux (EPEL), que proporciona paquetes adicionales no incluidos en los repositorios por defecto.

         - `dnf -y install bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer`: Instala herramientas y utilidades adicionales para gestionar máquinas virtuales de KVM, incluyendo bridge-utils para configurar puentes de red, virt-top para monitorizar el rendimiento de las máquinas virtuales, libguestfs-tools para manipular imágenes de disco de máquinas virtuales y virt-viewer para ver las consolas de las máquinas virtuales.

         - `systemctl start libvirtd`: Inicia el servicio libvirtd, que es responsable de gestionar las capacidades de virtualización en el sistema anfitrión.

         - `systemctl enable libvirtd`: Habilita el servicio libvirtd para que se inicie automáticamente al arrancar el sistema.

         - `systemctl status libvirtd`: Comprueba el estado del servicio libvirtd.

         - `usermod -aG libvirt $USER`: Añade el usuario actual al grupo libvirt, permitiéndole gestionar máquinas virtuales sin privilegios de root.

         - `newgrp libvirt`: Activa la pertenencia al grupo libvirt para el usuario actual sin necesidad de cerrar sesión y volver a iniciarla.

         - `brctl show`: Muestra la configuración actual del puente de red.

         - `nmcli connection show`: Muestra las conexiones de red configuradas en el sistema.

         Asegúrate de ejecutar estos comandos con los privilegios adecuados y revisa los requisitos del sistema antes de continuar con la configuración del clúster KVM.
   

   3. **Instalación de Terraform y Ansible**:
      - Configurar ambos para automatizar la infraestructura y la configuración del clúster.

Si el resultado es un número mayor que 0, tu procesador soporta virtualización. Si el resultado es 0, es posible que necesites entrar en la BIOS/UEFI de tu sistema para habilitar la virtualización.


## 2. Diseño de Infraestructura

   1. **Creación de Scripts de Terraform**:
      - Desarrollar scripts para configurar redes virtuales y asignar recursos como almacenamiento.
   2. **Configuración de Almacenamiento Persistente**:
      - Integrar soluciones como NFS o SAN para soportar las demandas del clúster.

## 3. Instalación del Clúster OpenShift

   1. **Despliegue del Nodo Bootstrap**:
      - Utilizar Terraform para automatizar la creación del nodo Bootstrap, configurando los parámetros esenciales para el clúster.
   2. **Instalación de Nodos Master y Worker**:
      - Implementar estos nodos a través de Terraform y configurarlos con Ansible para roles específicos dentro del clúster.

## 4. Configuración de Servicios Adicionales

   1. **Implementación de FreeIPA**:
      - Configurar FreeIPA para la gestión de identidades y políticas de acceso.
   2. **Configuración de Balanceadores de Carga**:
      - Utilizar tecnologías como Nginx o HAProxy para equilibrar la carga de tráfico de las aplicaciones.

## 5. Monitoreo y Alertas

   1. **Configuración de Prometheus**:
      - Establecer Prometheus para el monitoreo constante, configurando puntos de recolección de métricas y alertas.
   2. **Implementación de Grafana**:
      - Configurar dashboards en Grafana para visualizar las métricas y facilitar análisis en tiempo real.

## 6. Automatización con Ansible

   1. **Desarrollo de Playbooks**:
      - Crear y gestionar playbooks de Ansible para automatizar la instalación, configuración y mantenimiento del clúster.
   2. **Programación de Mantenimiento Automático**:
      - Establecer tareas automatizadas para el mantenimiento regular y gestión de incidentes, asegurando la estabilidad del clúster.
