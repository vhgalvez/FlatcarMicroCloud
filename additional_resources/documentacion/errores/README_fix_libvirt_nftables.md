# Fix de libvirt con firewall_backend = "nftables" y Terraform

## ✨ Contexto
Al utilizar `libvirt` con Terraform para aprovisionar recursos de red (NAT), apareció el siguiente error:

```bash
Error: error retrieving libvirt pool: No se pudo conectar socket a '/var/run/libvirt/virtstoraged-sock'
```

Este problema estaba relacionado con el uso de `firewall_backend = "nftables"` en la configuración de libvirt, y el hecho de que `libvirtd` está deprecated desde versiones recientes en favor de demonios separados (`virtqemud`, `virtlogd`, etc.).

---

## 🔧 Solución paso a paso

### 1. Detener y deshabilitar `libvirtd`
```bash
sudo systemctl stop libvirtd
sudo systemctl disable libvirtd
```

### 2. Habilitar demonios modernos
```bash
sudo systemctl enable --now virtqemud.service virtlogd.service virtproxyd.service
sudo systemctl enable --now virtnetworkd.service
sudo systemctl enable --now virtstoraged.service
```

### 3. Establecer nftables como backend del firewall
Editar `/etc/libvirt/libvirtd.conf`:
```ini
firewall_backend = "nftables"
```

### 4. Reiniciar demonios de libvirt y nftables
```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart virtqemud
sudo systemctl restart nftables
```

### 5. Verificar soporte de ip_tables
```bash
lsmod | grep ip_tables
sudo modprobe ip_tables
```

### 6. Validar redes definidas por libvirt
```bash
sudo virsh net-list --all
```

### 7. Inspeccionar reglas de `nftables`
```bash
sudo nft list ruleset | grep -i virbr
```

### 8. Verificar logs de errores (opcional)
```bash
sudo journalctl -u virtqemud -b | grep firewall
```

### 9. Limpiar y reiniciar logs (opcional)
```bash
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s
```

### 10. Ejecutar terraform
```bash
sudo terraform init --upgrade
sudo terraform plan
sudo terraform apply
```

---

## 🚀 Resultado
- Terraform funciona correctamente.
- Las redes NAT aparecen activas.
- Ya no hay errores al conectar con `virtstoraged-sock`.

---

## 🔍 Verificación final
```bash
sudo virsh net-list --all
sudo systemctl status virtqemud virtnetworkd virtstoraged
```

---

## 📅 Historial de comandos relevantes (resumido)
```bash
sudo systemctl stop libvirtd
sudo systemctl disable libvirtd
sudo systemctl enable --now virtqemud.service virtlogd.service virtproxyd.service
sudo systemctl enable --now virtnetworkd.service virtstoraged.service
sudo nano /etc/libvirt/libvirtd.conf
# Cambiar: firewall_backend = "nftables"
sudo systemctl daemon-reexec && sudo systemctl daemon-reload
sudo systemctl restart virtqemud nftables
sudo terraform apply
```

---

> Documentado desde `history` de bash por [victory@virtualizacion-server]

