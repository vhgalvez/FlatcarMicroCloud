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
sudo virsh shutdown freeipa1
sudo virsh shutdown load_balancer1
sudo virsh shutdown postgresql1
sudo virsh shutdown master3
sudo virsh shutdown master2
sudo virsh shutdown worker1
sudo virsh shutdown bootstrap1
sudo virsh shutdown worker2
sudo virsh shutdown worker3
sudo virsh shutdown master1
sudo virsh shutdown helper
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
sudo virsh start bastion1.cefaslocalserver.com
sudo virsh start freeipa1
sudo virsh start load_balancer1
sudo virsh start postgresql1
sudo virsh start bootstrap
sudo virsh start helper
sudo virsh start master1
sudo virsh start master2
sudo virsh start master3
sudo virsh start worker1
sudo virsh start worker2
sudo virsh start worker3
```