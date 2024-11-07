
# Documento Técnico: Instalación de Rocky Linux
## Descarga e Instalación de Rocky Linux

Primero, descarga la imagen ISO de Rocky Linux desde el sitio oficial:

```bash
mkdir -p /home/$USER/opt/isos
wget -P /home/$USER/opt/isos https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.3-x86_64-minimal.iso
```

A continuación, instala Rocky Linux en una máquina virtual:

```bash
sudo virt-install \
    --name RockyLinuxDNS \
    --memory 2048 \
    --vcpus 2 \
    --os-type linux \
    --os-variant generic \
    --disk path=/var/lib/libvirt/images/RockyLinuxDNS.qcow2,size=20 \
    --cdrom /home/$USER/opt/isos/Rocky-9.3-x86_64-minimal.iso \
    --network network=default,model=virtio \
    --graphics vnc,listen=0.0.0.0 \
    --noautoconsole
```

Para conectarte via VNC:

```bash
sudo virsh vncdisplay RockyLinuxDNS
```
