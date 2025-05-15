# ✅ Pasos para Migrar de libvirtd a virtqemud Correctamente

## 1. Detener el Servicio libvirtd

Detén el servicio `libvirtd` y su socket asociado:

```bash
sudo systemctl stop libvirtd
sudo systemctl stop libvirtd.socket
```

## 2. Deshabilitar libvirtd para que no se Inicie al Arrancar

Deshabilita el servicio y el socket de `libvirtd`:

```bash
sudo systemctl disable libvirtd
sudo systemctl disable libvirtd.socket
```

## 3. Habilitar y Arrancar los Demonios Modulares

Activa los demonios necesarios para la gestión modular, incluyendo `virtqemud`:

```bash
for drv in qemu network nodedev nwfilter secret storage; do
    sudo systemctl unmask virt${drv}d.service
    sudo systemctl unmask virt${drv}d.socket
    sudo systemctl enable virt${drv}d.service
    sudo systemctl enable virt${drv}d.socket
done
```

## 4. Verificar que virtqemud esté Activo

Comprueba el estado del servicio `virtqemud`:

```bash
systemctl is-active virtqemud
```

Si el estado es `active`, la migración ha sido exitosa.

## 5. Actualizar las Conexiones de virsh y virt-manager

### Configuración para virsh

Asegúrate de que apunte a la nueva URI:

```bash
virsh -c qemu:///system
```

### Configuración para virt-manager

Al abrir virt-manager, selecciona la conexión `qemu:///system`.

## 6. Migrar Máquinas Virtuales Existentes

Si tienes máquinas virtuales definidas bajo `qemu:///session`, puedes migrarlas a `qemu:///system` exportando e importando sus definiciones:

### Exportar la Definición de la Máquina Virtual

```bash
virsh dumpxml nombre_vm > nombre_vm.xml
```

### Eliminar la Definición Actual

```bash
virsh undefine nombre_vm
```

### Importar la Definición bajo el Nuevo URI

```bash
sudo virsh -c qemu:///system define nombre_vm.xml
```

Asegúrate de que las imágenes de disco sean accesibles por el usuario `libvirt-qemu`.

## 7. Configurar nftables como Firewall

Edita el archivo `/etc/libvirt/qemu.conf` para habilitar el soporte de `nftables`:

```ini
firewall_driver = "nftables"
```

Reinicia los servicios de libvirt y virtqemud para aplicar los cambios:

```bash
sudo systemctl restart virtqemud
```

Verifica que el módulo `nftables` esté cargado correctamente:

```bash
lsmod | grep nft
```

## 8. Reiniciar Todos los Servicios Relacionados

Reinicia todos los servicios relacionados con libvirt y QEMU:

```bash
sudo systemctl restart virtqemud.service virtlogd.service virtproxyd.service virtnetworkd.service virtstoraged.service
```

Para reiniciar todos juntos:

```bash
sudo systemctl restart virtqemud virtlogd virtproxyd virtnetworkd virtstoraged nftables NetworkManager
```

## ⚠️ Consideraciones Adicionales

- **Conexión Remota**: Si planeas gestionar máquinas virtuales de forma remota, considera habilitar y configurar `virtproxyd` para facilitar las conexiones seguras.
- **Compatibilidad de Máquinas Virtuales**: Asegúrate de que las configuraciones de hardware virtual (como el tipo de máquina y los dispositivos) sean compatibles con la nueva configuración.
- **Actualizaciones de Sistema**: Si estás utilizando una distribución basada en Red Hat (como RHEL o CentOS), es posible que ya estés utilizando los demonios modulares por defecto.

---

Siguiendo estos pasos, podrás migrar de manera efectiva de `libvirtd` a `virtqemud`, aprovechando las ventajas de una arquitectura modular y mejorando la seguridad y el rendimiento de la gestión de tus máquinas virtuales.