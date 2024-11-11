# Documento Técnico de Preparación del Ambiente para el Proyecto

Este documento detalla los pasos necesarios para preparar el ambiente y configurar el sistema para desplegar máquinas virtuales usando Terraform y Libvirt. A continuación, se explican paso a paso las tareas requeridas.

## Paso 1: Instalación de Dependencias

### Instalación de QEMU, KVM y Libvirt y terraform

Ejecuta los siguientes comandos para instalar las herramientas necesarias:

#### Instalación de QEMU, KVM y Libvirt

```bash
sudo dnf install -y qemu-kvm qemu-img libvirt libvirt-client virt-install
sudo dnf install -y epel-release
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd
sudo usermod -aG libvirt $USER
newgrp libvirt
brctl show
nmcli connection show
```

#### Instalación de Terraform

Agregar el Repositorio de HashiCorp

Primero, agrega el repositorio de HashiCorp a tu sistema:

```bash
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
```
Instalar Terraform

Luego, instala Terraform usando dnf:

```bash
sudo dnf -y install terraform
```
Verificar la Instalación

Finalmente, verifica que Terraform se haya instalado correctamente:

``` bash
terraform -version
```

Deberías ver la versión de Terraform instalada, confirmando que la instalación fue exitosa.

## Paso 2: Configuración del Pool de Almacenamiento

Creación Manual del Pool default
Primero, definimos, construimos, iniciamos y configuramos el pool default para que se inicie automáticamente con el sistema:

```bash
sudo virsh pool-define-as --name default --type dir --target /mnt/lv_data
sudo virsh pool-build default
sudo virsh pool-start default
sudo virsh pool-autostart default
```

Verificación de la Creación del Pool
Verifica que el pool se haya creado y esté activo:


```bash 
sudo virsh pool-list --all
```

## Paso 3: Descarga de Imágenes
Descarga de la Imagen de Flatcar Linux y Verificación
Crear el directorio y descargar la imagen:

```bash
mkdir -p /var/lib/libvirt/images/flatcar-linux
cd /var/lib/libvirt/images/flatcar-linux
wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img{,.sig}
```
Verificar la firma de la imagen:

```bash
gpg --verify flatcar_production_qemu_image.img.sig
```
Nota: Si obtienes un error de clave pública, 
importa la clave pública de Flatcar:

```bash
gpg --keyserver keyserver.ubuntu.com --recv-keys 85F7C8868837E271
gpg --verify flatcar_production_qemu_image.img.sig
```
Creación de la Imagen QCOW2 para Flatcar Linux
Crear la imagen snapshot:

```bash
qemu-img create -f qcow2 -F qcow2 -b /var/lib/libvirt/images/flatcar-linux/flatcar_production_qemu_image.img /var/lib/libvirt/images/flatcar-linux/flatcar-linux1.qcow2
```

Descarga de la Imagen de Rocky Linux 9
Descargar la imagen de Rocky Linux 9 Generic Cloud en formato QCOW2:

```bash
cd /var/lib/libvirt/images
wget https://download.rockylinux.org/pub/rocky/9/images/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
```


# Descarga y Preparación de la Imagen de Flatcar Container Linux

Has descargado y descomprimido correctamente la imagen de Flatcar Container Linux en formato QCOW2. A continuación, se detallan los pasos que has seguido:

### 1. Descarga de la Imagen Comprimida

Utilizaste `curl` con privilegios de superusuario para descargar la imagen comprimida desde el sitio oficial de Flatcar:

```bash
sudo curl -o /mnt/lv_data/organized_storage/images/flatcar_production_qemu_image.img.bz2 https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_qemu_image.img.bz2
```

Este comando guarda el archivo flatcar_production_qemu_image.img.bz2 en el directorio especificado.

2. Descompresión de la Imagen
Después de la descarga, descomprimiste el archivo utilizando bunzip2:

```bash
sudo bunzip2 /mnt/lv_data/organized_storage/images/flatcar_production_qemu_image.img.bz2
```
Este comando descomprime el archivo .bz2, resultando en flatcar_production_qemu_image.img.

3. Verificación de la Imagen Descomprimida
Finalmente, listaste el contenido del directorio para confirmar la presencia de la imagen descomprimida:

```bash
ls -l /mnt/lv_data/organized_storage/images/
```
La salida muestra que flatcar_production_qemu_image.img está presente con un tamaño de aproximadamente 489 MB.

Con estos pasos, la imagen de Flatcar Container Linux está lista para ser utilizada en tu entorno de virtualización.
