#!/bin/bash

# Crear directorios necesarios
sudo mkdir -p /opt/bin /etc/kubernetes/pki /opt/cni/bin /etc/kubernetes/pki/etcd
sudo mkdir -p /opt/cni/bin
sudo mkdir -p  /home/core/bin/mksquashfs
sudo mkdir -p /home/core/bin

export PATH=$PATH:/home/core/bin


# Descargar e instalar CRI-O (v1.30.5)
sudo wget -O /tmp/crio.tar.gz https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.v1.30.5.tar.gz
sudo tar -xzf /tmp/crio.tar.gz -C /opt/cni/bin/
sudo cp /opt/bin/crio/cri-o/cni-plugins/* /opt/cni/bin/


sudo systemctl daemon-reload
sudo systemctl enable extensions-crio.slice
sudo systemctl start extensions-crio.slice

sudo mount -o remount,rw /
mount | grep " / "

sudo docker run -it --rm alpine
apk add squashfs-tools


Copia el binario mksquashfs al sistema Flatcar:

Primero, abre una nueva ventana de terminal y busca el ID del contenedor de Alpine que está corriendo:

sudo docker ps

sudo chmod +x /usr/local/bin/mksquashfs




sudo docker cp <container_id>:/usr/bin/mksquashfs /home/core/bin/mksquashfs
sudo chmod +x /home/core/bin/mksquashfs


sudo docker cp ad2c56e6dfe9:/usr/bin/mksquashfs /home/core/bin/mksquashfs
sudo chmod +x /home/core/bin/mksquashfs



sudo mkdir -p /home/core/bin
sudo docker cp fdbabb749b1d:/usr/bin/mksquashfs /home/core/bin/mksquashfs
sudo chmod +x /home/core/bin/mksquashfs


sudo mkdir -p /home/core/bin/mksquashfs
export PATH=$PATH:/home/core/bin

/home/core/bin/mksquashfs --version


sudo wget https://raw.githubusercontent.com/flatcar/sysext-bakery/main/bake.sh -O bake.sh
sudo chmod +x bake.sh
sudo ./bake.sh

sudo wget https://raw.githubusercontent.com/flatcar/sysext-bakery/main/create_crio_sysext.sh -O create_crio_sysext.sh
sudo chmod +x create_crio_sysext.sh
sudo ./create_crio_sysext.sh 1.30.5 crio-sysext



sudo /usr/local/bin/crio/cri-o/install


ls -l /opt/bin/crio/crio
sudo systemctl daemon-reload
sudo systemctl start crio
sudo systemctl enable --now crio




sudo docker exec -it 1d423cbb6ce3 /bin/sh
apk add lz4-libs lzo zstd-libs xz-libs

sudo docker cp 1d423cbb6ce3:/usr/lib/liblz4.so.1 /home/core/lib/
sudo docker cp 1d423cbb6ce3:/usr/lib/liblzo2.so.2 /home/core/lib/
sudo docker cp 1d423cbb6ce3:/usr/lib/libzstd.so.1 /home/core/lib/
sudo docker cp 1d423cbb6ce3:/usr/lib/libz.so.1 /home/core/lib/
sudo docker cp 1d423cbb6ce3:/usr/lib/liblzma.so.5 /home/core/lib/


export LD_LIBRARY_PATH=/home/core/lib:$LD_LIBRARY_PATH
/home/core/lib/ld-musl-x86_64.so.1 --library-path /home/core/lib /home/core/bin/mksquashfs --version







sudo docker exec -it <container_id> /bin/sh
apk add lz4-libs lzo zstd-libs xz-libs
sudo docker cp <container_id>:/usr/lib/liblz4.so.1 /home/core/lib/
sudo docker cp <container_id>:/usr/lib/liblzo2.so.2 /home/core/lib/
sudo docker cp <container_id>:/usr/lib/libzstd.so.1 /home/core/lib/
sudo docker cp <container_id>:/usr/lib/libz.so.1 /home/core/lib/
sudo docker cp <container_id>:/usr/lib/liblzma.so.5 /home/core/lib/



export LD_LIBRARY_PATH=/home/core/lib:$LD_LIBRARY_PATH
/home/core/bin/mksquashfs --version






# Verifica el estado de la partición raíz
mount | grep " / "

# Verifica el estado de SELinux
getenforce

# Cambia temporalmente SELinux a modo permisivo
sudo setenforce 0

# Remonta la partición raíz con permisos de escritura
sudo mount -o remount,rw /

# Verifica errores en el sistema de archivos
sudo dmesg | grep "EXT4-fs error"
sudo fsck /dev/vda9  # Reemplaza con la partición correcta si es diferente

# Si fsck no puede ejecutarse, crea un archivo para forzar el chequeo al reiniciar
sudo touch /forcefsck

# Reinicia el sistema para ejecutar fsck automáticamente
sudo reboot

# Intenta extraer archivos en un directorio diferente si /usr/local/bin/ está en modo solo lectura
sudo mkdir -p /home/core/crio/
sudo tar -xzf /tmp/crio.tar.gz -C /home/core/crio/





core@bootstrap ~ $ sudo mount | grep " / "
/dev/vda9 on / type ext4 (rw,relatime,seclabel)
core@bootstrap ~ $ sudo mount -o remount,rw /
core@bootstrap ~ $ mount | grep " / "
/dev/vda9 on / type ext4 (rw,relatime,seclabel)
core@bootstrap ~ $ sudo dmesg | grep "EXT4-fs error"
core@bootstrap ~ $ sudo touch /forcefsck
core@bootstrap ~ $
sudo reboot

https://www.flatcar.org/  https://okd.io/ https://www.redhat.com/es
https://docs.okd.io/3.11/crio/crio_runtime.html
https://github.com/okd-project/okd https://cri-o.io/
https://kubernetes.io/


#/usr/bin/env sh
set -ex
# Descargar e instalar CRI-O (v1.30.5)
sudo wget -O /tmp/crio.tar.gz https://storage.googleapis.com/cri-o/artifacts/cri-o.amd64.v1.30.5.tar.gz
sudo tar -xzf /tmp/crio.tar.gz -C /opt/bin/


sudo systemctl daemon-reload
sudo systemctl enable extensions-crio.slice
sudo systemctl start extensions-crio.slice

# Crear directorios necesarios
sudo mkdir -p /opt/cni/bin
sudo /opt/bin/cri-o/install

export PATH=$PATH:/opt/bin/
export PATH=$PATH:/opt/bin/cri-o/bin/


set -ex

# Variables de entorno y rutas
DESTDIR=${DESTDIR:-}
PREFIX=${PREFIX:-/opt}
ETCDIR=${ETCDIR:-/etc}
LIBEXECDIR=${LIBEXECDIR:-/opt/libexec}
LIBEXEC_CRIO_DIR=${LIBEXEC_CRIO_DIR:-$LIBEXECDIR/crio}
ETC_CRIO_DIR=${ETC_CRIO_DIR:-$ETCDIR/crio}
CONTAINERS_DIR=${CONTAINERS_DIR:-$ETCDIR/containers}
CONTAINERS_REGISTRIES_CONFD_DIR=${CONTAINERS_REGISTRIES_CONFD_DIR:-$CONTAINERS_DIR/registries.conf.d}
CNIDIR=${CNIDIR:-$ETCDIR/cni/net.d}
BINDIR=${BINDIR:-$PREFIX/bin}
MANDIR=${MANDIR:-$PREFIX/share/man}
OCIDIR=${OCIDIR:-$PREFIX/share/oci-umount/oci-umount.d}
BASHINSTALLDIR=${BASHINSTALLDIR:-$PREFIX/share/bash-completion/completions}
FISHINSTALLDIR=${FISHINSTALLDIR:-$PREFIX/share/fish/completions}
ZSHINSTALLDIR=${ZSHINSTALLDIR:-$PREFIX/share/zsh/site-functions}
OPT_CNI_BIN_DIR=${OPT_CNI_BIN_DIR:-/opt/cni/bin}

# Ajustar SYSCONFIGDIR para distribuciones basadas en Debian
if dpkg -l >/dev/null 2>&1; then
    SYSCONFIGDIR=${SYSCONFIGDIR:-$ETCDIR/default}
    sed -i "s;sysconfig/crio;default/crio;g" etc/crio
else
    SYSCONFIGDIR=${SYSCONFIGDIR:-$ETCDIR/sysconfig}
fi

# Actualizar systemddir según el sistema operativo
source /etc/os-release
if { [[ "${ID}" == "fedora" ]] && [[ "${VARIANT_ID}" == "coreos" ]]; } ||
    [[ "${ID}" == "rhcos" ]]; then
    SYSTEMDDIR=${SYSTEMDDIR:-/etc/systemd/system}
else
    SYSTEMDDIR=${SYSTEMDDIR:-$PREFIX/lib/systemd/system}
fi

SELINUX=
if selinuxenabled 2>/dev/null; then
    SELINUX=-Z
fi
ARCH=${ARCH:-amd64}

# Instalación de directorios y archivos necesarios
install $SELINUX -d -m 755 "$DESTDIR$CNIDIR"
install $SELINUX -D -m 755 -t "$DESTDIR$OPT_CNI_BIN_DIR" /opt/bin/cri-o/cni-plugins/*
install $SELINUX -D -m 644 -t "$DESTDIR$CNIDIR" /opt/bin/cri-o/contrib/11-crio-ipv4-bridge.conflist
install $SELINUX -d -m 755 "$DESTDIR$LIBEXEC_CRIO_DIR"
install $SELINUX -D -m 755 -t "$DESTDIR$LIBEXEC_CRIO_DIR" /opt/bin/cri-o/bin/conmon
install $SELINUX -D -m 755 -t "$DESTDIR$LIBEXEC_CRIO_DIR" /opt/bin/cri-o/bin/conmonrs
install $SELINUX -D -m 755 -t "$DESTDIR$LIBEXEC_CRIO_DIR" /opt/bin/cri-o/bin/crun
install $SELINUX -D -m 755 -t "$DESTDIR$LIBEXEC_CRIO_DIR" /opt/bin/cri-o/bin/runc
install $SELINUX -d -m 755 "$DESTDIR$BASHINSTALLDIR"
install $SELINUX -d -m 755 "$DESTDIR$FISHINSTALLDIR"
install $SELINUX -d -m 755 "$DESTDIR$ZSHINSTALLDIR"
install $SELINUX -d -m 755 "$DESTDIR$CONTAINERS_REGISTRIES_CONFD_DIR"
install $SELINUX -D -m 755 -t "$DESTDIR$BINDIR" /opt/bin/cri-o/bin/crio
install $SELINUX -D -m 755 -t "$DESTDIR$BINDIR" /opt/bin/cri-o/bin/pinns
install $SELINUX -D -m 755 -t "$DESTDIR$BINDIR" /opt/bin/cri-o/bin/crictl
install $SELINUX -D -m 644 -t "$DESTDIR$ETCDIR" /opt/bin/cri-o/etc/crictl.yaml
install $SELINUX -D -m 644 -t "$DESTDIR$OCIDIR" /opt/bin/cri-o/etc/crio-umount.conf
install $SELINUX -D -m 644 -t "$DESTDIR$SYSCONFIGDIR" /opt/bin/cri-o/etc/crio
install $SELINUX -D -m 644 -t "$DESTDIR$ETC_CRIO_DIR" /opt/bin/cri-o/contrib/policy.json
install $SELINUX -D -m 644 -t "$DESTDIR$ETC_CRIO_DIR/crio.conf.d" /opt/bin/cri-o/etc/10-crio.conf
install $SELINUX -D -m 644 -t "$DESTDIR$MANDIR/man5" /opt/bin/cri-o/man/crio.conf.5
install $SELINUX -D -m 644 -t "$DESTDIR$MANDIR/man5" /opt/bin/cri-o/man/crio.conf.d.5
install $SELINUX -D -m 644 -t "$DESTDIR$MANDIR/man8" /opt/bin/cri-o/man/crio.8
install $SELINUX -D -m 644 -t "$DESTDIR$BASHINSTALLDIR" /opt/bin/cri-o/completions/bash/crio
install $SELINUX -D -m 644 -t "$DESTDIR$FISHINSTALLDIR" /opt/bin/cri-o/completions/fish/crio.fish
install $SELINUX -D -m 644 -t "$DESTDIR$ZSHINSTALLDIR" /opt/bin/cri-o/completions/zsh/_crio
install $SELINUX -D -m 644 -t "$DESTDIR$SYSTEMDDIR" /opt/bin/cri-o/contrib/crio.service
install $SELINUX -D -m 644 -t "$DESTDIR$CONTAINERS_REGISTRIES_CONFD_DIR" /opt/bin/cri-o/contrib/registries.conf

# Actualizar las rutas en la configuración de CRI-O
sed -i 's;/usr/bin;'"$DESTDIR$BINDIR"';g' "$DESTDIR$ETC_CRIO_DIR/crio.conf.d/10-crio.conf"
sed -i 's;/usr/libexec;'"$DESTDIR$LIBEXECDIR"';g' "$DESTDIR$ETC_CRIO_DIR/crio.conf.d/10-crio.conf"
sed -i 's;/etc/crio;'"$DESTDIR$ETC_CRIO_DIR"';g' "$DESTDIR$ETC_CRIO_DIR/crio.conf.d/10-crio.conf"

# Aplicar etiquetas SELinux si está habilitado
if [ -n "$SELINUX" ]; then
    if command -v chcon >/dev/null; then
        chcon -u system_u -r object_r -t container_runtime_exec_t \
            "$DESTDIR$BINDIR/crio" \
            "$DESTDIR$LIBEXEC_CRIO_DIR/crun" \
            "$DESTDIR$LIBEXEC_CRIO_DIR/runc"

        chcon -u system_u -r object_r -t bin_t \
            "$DESTDIR$LIBEXEC_CRIO_DIR/conmon" \
            "$DESTDIR$LIBEXEC_CRIO_DIR/conmonrs" \
            "$DESTDIR$BINDIR/crictl" \
            "$DESTDIR$BINDIR/pinns"

        chcon -R -u system_u -r object_r -t bin_t \
            "$DESTDIR$OPT_CNI_BIN_DIR" \
            "$DESTDIR$LIBEXEC_CRIO_DIR"

        chcon -R -u system_u -r object_r -t container_config_t \
            "$DESTDIR$ETC_CRIO_DIR" \
            "$DESTDIR$OCIDIR/crio-umount.conf"

        chcon -R -u system_u -r object_r -t systemd_unit_file_t \
            "$DESTDIR$SYSTEMDDIR/crio.service"
    fi
fi