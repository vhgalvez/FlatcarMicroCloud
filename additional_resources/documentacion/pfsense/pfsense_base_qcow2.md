# Pasos para optimizar y mover la imagen QCOW2

## 1. Optimizar la imagen original

Utiliza `qemu-img` para generar una versión optimizada de la imagen QCOW2 original. Este proceso no modifica el archivo original, sino que crea un nuevo archivo optimizado.

```bash
qemu-img convert -O qcow2 /var/lib/libvirt/images/pfsense_base.qcow2 /var/lib/libvirt/images/pfsense_base_optimized.qcow2
```

## 2. Verificar tamaños

Comprueba el tamaño de ambas imágenes (original y optimizada) para confirmar que la optimización fue exitosa.

```bash
ls -lh /var/lib/libvirt/images/pfsense_base.qcow2
ls -lh /var/lib/libvirt/images/pfsense_base_optimized.qcow2
```
## 3. Mover las imágenes a la nueva ubicación

Mantén la imagen original en su ubicación actual y copia ambas imágenes (original y optimizada) a la carpeta destinada para Terraform. Esto asegura que ambas versiones estén disponibles para diferentes propósitos.

Copiar la imagen original:

```bash
sudo cp /var/lib/libvirt/images/pfsense_base.qcow2 /mnt/lv_data/organized_storage/images/pfsense_base.qcow2
```
## Copiar la imagen optimizada:

```bash
sudo cp -R /var/lib/libvirt/images/pfsense_base_optimized.qcow2 /mnt/lv_data/organized_storage/images/pfsense_base_optimized.qcow2
```
## 4. Asignar permisos correctos

Asegúrate de que las imágenes en la nueva ubicación tengan los permisos y propietarios adecuados para que libvirt y qemu puedan acceder a ellas.

Permisos para la imagen original:


```bash
sudo chown qemu:qemu /mnt/lv_data/organized_storage/images/pfsense_base.qcow2
sudo chmod 775 /mnt/lv_data/organized_storage/images/pfsense_base.qcow2
```

Permisos para la imagen optimizada:

```bash
sudo chown qemu:qemu /mnt/lv_data/organized_storage/images/pfsense_base_optimized.qcow2
sudo chmod 775 /mnt/lv_data/organized_storage/images/pfsense_base_optimized.qcow2
```


## 5. Verificar las imágenes movidas

Confirma que las imágenes han sido copiadas correctamente y tienen los permisos adecuados.

```bash
ls -lh /mnt/lv_data/organized_storage/images/pfsense_base.qcow2
ls -lh /mnt/lv_data/organized_storage/images/pfsense_base_optimized.qcow2
```

## 6. Reiniciar el servicio sshd

```bash
service sshd restart    
```

