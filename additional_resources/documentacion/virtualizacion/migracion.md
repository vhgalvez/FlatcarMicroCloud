✅ Pasos para migrar de libvirtd a virtqemud correctamente

### Detener el servicio libvirtd:

```bash
sudo systemctl stop libvirtd
sudo systemctl stop libvirtd.socket
```

### Deshabilitar libvirtd para que no se inicie al arrancar:

```bash
sudo systemctl disable libvirtd
sudo systemctl disable libvirtd.socket
```

### Habilitar y arrancar los demonios modulares:

```bash
for drv in qemu network nodedev nwfilter secret storage; do
    sudo systemctl unmask virt${drv}d.service
    sudo systemctl unmask virt${drv}d.socket
    sudo systemctl enable virt${drv}d.service
    sudo systemctl enable virt${drv}d.socket
done
```

Esto activará los demonios necesarios, incluyendo `virtqemud` para la gestión de QEMU.

### Verificar que virtqemud esté activo:

```bash
systemctl is-active virtqemud
```

Si el estado es `active`, la migración ha sido exitosa.

### Actualizar las conexiones de virsh y virt-manager:

Asegúrate de que tus herramientas de gestión de máquinas virtuales apunten a la nueva URI:

#### Para virsh:

```bash
virsh -c qemu:///system
```

#### Para virt-manager:

Al abrir virt-manager, selecciona la conexión `qemu:///system`.

### Migrar máquinas virtuales existentes:

Si tienes máquinas virtuales definidas bajo `qemu:///session`, puedes migrarlas a `qemu:///system` exportando e importando sus definiciones:

#### Exportar la definición de la máquina virtual:

```bash
virsh dumpxml nombre_vm > nombre_vm.xml
```

#### Eliminar la definición actual:

```bash
virsh undefine nombre_vm
```

#### Importar la definición bajo el nuevo URI:

```bash
sudo virsh -c qemu:///system define nombre_vm.xml
```

Asegúrate de que las imágenes de disco sean accesibles por el usuario `libvirt-qemu`.

---

## ⚠️ Consideraciones adicionales

- **Conexión remota**: Si planeas gestionar máquinas virtuales de forma remota, considera habilitar y configurar `virtproxyd` para facilitar las conexiones seguras.
- **Compatibilidad de máquinas virtuales**: Al migrar máquinas virtuales, asegúrate de que las configuraciones de hardware virtual (como el tipo de máquina y los dispositivos) sean compatibles con la nueva configuración.
- **Actualizaciones de sistema**: Si estás utilizando una distribución basada en Red Hat (como RHEL o CentOS), es posible que ya estés utilizando los demonios modulares por defecto.

---

Siguiendo estos pasos, podrás migrar de manera efectiva de `libvirtd` a `virtqemud`, aprovechando las ventajas de una arquitectura modular y mejorando la seguridad y el rendimiento de la gestión de tus máquinas virtuales.



/etc/libvirt/qemu.conf. Añade o edita la línea para habilitar el soporte de nftables:

ini
Copiar
Editar
firewall_driver = "nftables"
Reinicia los servicios de libvirt y virtqemud: Después de realizar los cambios, reinicia el servicio virtqemud y asegúrate de que no se detenga ni se reinicie:

bash
Copiar
Editar
sudo systemctl restart virtqemud
Revisa los logs para errores adicionales: Después de hacer estos cambios, revisa los logs de nuevo para asegurarte de que el problema se ha resuelto:

bash
Copiar
Editar
sudo journalctl -u virtqemud.service
Verifica que el módulo nftables esté cargado: Ya que has tenido problemas con modprobe nftables, verifica si el módulo nftables está cargado correctamente usando el siguiente comando:

bash
Copiar
Editar
lsmod | grep nft


firewall_backend = "nftables"
max_clients = 20
max_requests = 1000
[victory@virtualizacion-server nat_network_03]$ sudo cat /etc/libvirt/libvirtd.conf
