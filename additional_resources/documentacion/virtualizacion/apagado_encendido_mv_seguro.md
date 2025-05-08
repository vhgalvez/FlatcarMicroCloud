# Apagado Seguro de Máquinas Virtuales Utilizando virsh shutdown

Apagar las máquinas virtuales utilizando virsh shutdown debería realizar un apagado limpio del sistema operativo invitado y no debería dañar las configuraciones de DNS ni ningún otro servicio configurado en las máquinas virtuales. Aquí te dejo una explicación detallada para asegurarte de que todo esté en orden:

1. Apagado Limpio

El comando virsh shutdown envía una señal de apagado al sistema operativo invitado, permitiendo que los servicios, como el servidor DNS en freeipa1, se detengan correctamente. Esto es similar a apagar un servidor físico usando el botón de apagado en lugar de desconectarlo de la corriente.

2. Verificación de Apagado Completo

Una vez que envíes el comando de apagado, verifica que todas las máquinas virtuales están apagadas:

```bash
sudo virsh list --all
```

Asegúrate de que el estado de cada máquina virtual cambie a apagado (shut off).

3. Reinicio y Verificación de Servicios
   Cuando vuelvas a encender las máquinas virtuales, verifica que los servicios críticos, como DNS en freeipa1, estén funcionando correctamente:

```bash
sudo virsh start freeipa1
```

Luego, ingresa a la máquina virtual y verifica el estado del servicio DNS:

```bash
sudo virsh console freeipa1
```

# Una vez dentro de la máquina virtual

sudo systemctl status named

4. Ejemplo de Apagado de Todas las Máquinas Virtuales

```bash
sudo virsh shutdown bastion1.cefaslocalserver.com
sudo virsh shutdown load_balancer1
sudo virsh shutdown load_balancer2
sudo virsh shutdown postgresql1
sudo virsh shutdown freeipa1
sudo virsh shutdown worker3
sudo virsh shutdown master3
sudo virsh shutdown master1
sudo virsh shutdown worker1
sudo virsh shutdown master2
sudo virsh shutdown worker2
sudo virsh shutdown storage1
```

Verifica el estado final:

```bash
sudo virsh list --all
```

```bash
[victory@physical1 terraform-openshift-kvm-deployment_linux_Flatcar]$ sudo virsh list --all
 Id   Nombre                          Estado
-----------------------------------------------
 -    bastion1.cefaslocalserver.com   apagado
 -    bootstrap                      apagado
 -    freeipa1                        apagado
 -    load_balancer1                  apagado
 -    master1                         apagado
 -    master2                         apagado
 -    master3                         apagado
 -    postgresql1                     apagado
 -    worker1                         apagado
 -    worker2                         apagado
 -    worker3                         apagado
 -    helper                          apagado
```

Nota Adicional

Si tienes servicios críticos que no pueden ser interrumpidos, considera hacer un respaldo de las configuraciones antes de apagar las máquinas virtuales.

Respaldo de Configuración DNS (opcional)
Antes de proceder, puedes hacer un respaldo de los archivos de configuración de DNS en freeipa1:

```bash
sudo cp /etc/named.conf /etc/named.conf.backup
sudo cp -r /var/named /var/named.backup
```

Esto te permitirá restaurar la configuración en caso de cualquier problema.

## Resumen

Utilizando virsh shutdown es una forma segura de apagar tus máquinas virtuales sin dañar las configuraciones existentes si todo está configurado correctamente y se siguen los procedimientos adecuados de apagado y verificación.

Autor: [Tu Nombre]

Fecha: [Fecha de Creación del Documento]

Este documento proporciona una guía paso a paso para el apagado seguro de máquinas virtuales utilizando virsh shutdown y la verificación de servicios críticos después del reinicio.

```bash
sudo virsh start master1
sudo virsh start master2
sudo virsh start master3
sudo virsh start worker1
sudo virsh start worker2
sudo virsh start worker3

sudo virsh start storage1
sudo virsh start freeipa1
sudo virsh start load_balancer1
sudo virsh start load_balancer2

sudo virsh start bastion1.cefaslocalserver.com
sudo virsh start postgresql1

```



## Comandos Adicionales

```bash
sudo virsh list --all
```

# Deshabilitar SELinux

```bash
sudo setenforce 0
sudo systemctl restart libvirtd
```

[victory@physical1 ~]$ sudo sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
[victory@physical1 ~]$

curl -o /mnt/lv_data/organized_storage/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2 https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2

1. Cambiar el propietario a qemu (si es necesario para la VM)
Si estás utilizando Libvirt o alguna otra herramienta como qemu para manejar la imagen, lo ideal sería cambiar el propietario a qemu:

sudo chown qemu:qemu /mnt/lv_data/organized_storage/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2
Esto cambiará el propietario y el grupo del archivo a qemu, que es el usuario bajo el que Libvirt y otros servicios de virtualización suelen operar.

2. Cambiar los permisos para permitir acceso de escritura
Si prefieres que el archivo sea accesible para todos los usuarios (no solo root), puedes cambiar los permisos para que todos tengan acceso de lectura y escritura:

sudo chmod 664 /mnt/lv_data/organized_storage/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2
Esto da permisos de lectura y escritura al propietario y al grupo, y solo permisos de lectura a otros usuarios.

3. Verificar los cambios
Para asegurarte de que los permisos se aplicaron correctamente, puedes verificarlo con el siguiente comando:

ls -l /mnt/lv_data/organized_storage/images/AlmaLinux-9-GenericCloud-9.5-20241120.x86_64.qcow2


sudo virsh net-list --all

sudo virsh net-autostart default
sudo virsh net-autostart kube_network_02
sudo virsh net-autostart kube_network_03
sudo virsh net-autostart br0

sudo virsh net-start default
sudo virsh net-start kube_network_02
sudo virsh net-start kube_network_03
sudo virsh net-start br0



[victory@physical1 ~]$ sudo virsh net-list --all
 Nombre            Estado     Inicio automático   Persistente
---------------------------------------------------------------
 br0               activo     si                  si
 default           inactivo   si                  si
 kube_network_02   inactivo   si                  si
 kube_network_03   inactivo   si                  si

[victory@physical1 ~]$



| Equipo                | Sistema Operativo                    | CPU                                         | GPU                 | VRAM GPU  | RAM   | Almacenamiento Principal                     | Rol Ideal                                           |
| --------------------- | ------------------------------------ | ------------------------------------------- | ------------------- | --------- | ----- | -------------------------------------------- | --------------------------------------------------- |
| **PC con RTX 4070**   | Windows 11 Pro + WSL2 (Ubuntu 20.04) | AMD Ryzen 7 5700X (8 núcleos / 16 hilos)    | **NVIDIA RTX 4070** | **12 GB** | 32 GB | SSD NVMe + HDD 2 TB                          | ⚡ Generación IA de textos e imágenes (GPU + CPU)    |
| **Servidor HP DL380** | Rocky Linux 9.5 (Blue Onyx)          | 2x Intel Xeon X5650 (12 núcleos / 24 hilos) | AMD ES1000 (básica) | N/A       | 35 GB | / (70 GB) + /home (3 TB) + /var/lib (500 GB) | 🌐 Publicación masiva, almacenamiento y backend NFS |
