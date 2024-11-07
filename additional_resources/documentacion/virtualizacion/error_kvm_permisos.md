# Tutorial: Resolución de Problemas de Permisos en QEMU/KVM y Libvirt Después de Mover Datos de VM

## 1. Descripción del Problema
Después de mover las imágenes de máquinas virtuales (VM) y datos a una nueva partición, surgieron problemas de permisos en QEMU/KVM y libvirt que provocaron errores al intentar crear máquinas virtuales. Estos errores estaban relacionados con la denegación de acceso a archivos debido a permisos incorrectos de Unix y contextos de SELinux.

## 2. Requisitos Previos
- Asegúrate de que QEMU, KVM y libvirt estén correctamente instalados y configurados en tu sistema.
- SELinux debe estar habilitado y en modo "enforcing".

## 3. Solución Paso a Paso

### Paso 1: Verificar Propiedad y Permisos de Archivos
1. **Cambiar Propiedad**: Asegúrate de que todos los archivos y directorios en la nueva ubicación pertenezcan al usuario y grupo `qemu:qemu`.

    ```bash
    sudo chown -R qemu:qemu /mnt/lv_data/organized_storage/volumes/
    ```

2. **Establecer Permisos Correctos**: Ajusta los permisos para garantizar que QEMU pueda leer y acceder a los directorios.

    ```bash
    sudo chmod -R 755 /mnt/lv_data/organized_storage/volumes/
    ```

### Paso 2: Configurar los Contextos de SELinux
1. **Verificar Estado de SELinux**: Confirma que SELinux esté habilitado y en modo "enforcing".

    ```bash
    sestatus
    ```

2. **Aplicar el Contexto Correcto de SELinux**: Usa `semanage` para establecer el contexto SELinux adecuado para las imágenes de las máquinas virtuales. El contexto `virt_image_t` es el adecuado para estos archivos.

    ```bash
    sudo semanage fcontext -a -t virt_image_t '/mnt/lv_data/organized_storage/volumes(/.*)?'
    ```

3. **Aplicar Contexto Recursivamente**: Aplica el nuevo contexto de SELinux a todos los archivos y directorios existentes en la ruta especificada.

    ```bash
    sudo restorecon -Rv /mnt/lv_data/organized_storage/volumes/
    ```

### Paso 3: Reiniciar libvirtd y Reaplicar la Configuración
1. **Reiniciar libvirtd**: Después de realizar cambios en los permisos y contextos de SELinux, reinicia el demonio de libvirt para asegurarte de que los cambios tengan efecto.

    ```bash
    sudo systemctl restart libvirtd
    ```

2. **Reaplicar la Configuración con Terraform**: Si estás utilizando Terraform para gestionar tu infraestructura, reaplica la configuración para crear las máquinas virtuales.

    ```bash
    terraform apply
    ```

### Paso 4: Verificar Éxito
1. **Buscar Errores**: Si el script de Terraform se ejecuta con éxito y se crean las VMs, verifica si hay errores o problemas pendientes.

    ```bash
    sudo ausearch -m avc -ts recent
    ```

2. **Validar la Creación de Máquinas Virtuales**: Confirma que todas las máquinas virtuales se han creado y están funcionando correctamente verificando sus direcciones IP y estados.

    ```bash
    virsh list --all
    ```

### Paso 5: Configuración Adicional (si es necesario)
1. **Actualizar la Configuración de QEMU**: Si recibes advertencias sobre características obsoletas de QEMU, considera actualizar los tipos de máquinas y modelos de CPU a configuraciones más modernas.

    - **Tipo de Máquina**: Usa un tipo de máquina más reciente, como `pc-i440fx-rhel8.0.0`.
    - **Modelo de CPU**: Reemplaza `qemu64-x86_64-cpu` con `host` (para pasar la CPU del host) o un modelo de CPU más moderno como `Nehalem` o `Opteron_G4`.

2. **Volver a Probar en Modo Permisivo**: Si SELinux sigue causando problemas, puedes ponerlo temporalmente en modo permisivo para pruebas:

    ```bash
    sudo setenforce 0
    ```

    Después, vuelve a ejecutar el script de Terraform para verificar si SELinux es el problema. Retorna SELinux al modo "enforcing" después:

    ```bash
    sudo setenforce 1
    ```

## Conclusión
Siguiendo estos pasos, deberías haber resuelto exitosamente los problemas de permisos relacionados con QEMU/KVM y libvirt después de mover tus datos de VM a una nueva partición. Asegurarse de tener los permisos de Unix y contextos de SELinux correctos es crucial en un entorno seguro como el tuyo.

