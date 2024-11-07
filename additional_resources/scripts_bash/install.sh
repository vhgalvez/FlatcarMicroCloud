#/usr/bin/env sh
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