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



# Configuración de NAT para las interfaces de red de libvirt
table ip nat {
    # Cadena de post-routing para aplicar NAT
    chain postrouting {
        type nat hook postrouting priority srcnat; policy accept;

        # Mascarada para la subred 10.17.5.0/24
        ip saddr 10.17.5.0/24 oifname "enp4s0f0" masquerade
        
        # Mascarada para la subred 10.17.4.0/24
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" masquerade
        
        # Mascarada para la subred 10.17.3.0/24
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" masquerade
    }

    # Cadena LIBVIRT_PRT para el filtrado y mascarado del tráfico entre las redes NAT
    chain LIBVIRT_PRT {
        # Paquetes multicast para 224.0.0.0/24 (protocolo de red)
        ip saddr 10.17.4.0/24 ip daddr 224.0.0.0/24 counter packets 0 bytes 0 return
        ip saddr 10.17.4.0/24 ip daddr 255.255.255.255 counter packets 0 bytes 0 return
        
        # Mascarada para tráfico TCP/UDP hacia otras subredes que no sean la propia
        ip saddr 10.17.4.0/24 ip daddr != 10.17.4.0/24 ip protocol tcp counter packets 2 bytes 120 masquerade to :1024-65535
        ip saddr 10.17.4.0/24 ip daddr != 10.17.4.0/24 ip protocol udp counter packets 2 bytes 200 masquerade to :1024-65535
        ip saddr 10.17.4.0/24 ip daddr != 10.17.4.0/24 counter packets 0 bytes 0 masquerade
        
        # Paquetes multicast para 224.0.0.0/24 (protocolo de red) en otras subredes
        ip saddr 10.17.5.0/24 ip daddr 224.0.0.0/24 counter packets 0 bytes 0 return
        ip saddr 10.17.5.0/24 ip daddr 255.255.255.255 counter packets 0 bytes 0 return
        
        # Mascarada para tráfico TCP/UDP hacia otras subredes que no sean la propia
        ip saddr 10.17.5.0/24 ip daddr != 10.17.5.0/24 ip protocol tcp counter packets 0 bytes 0 masquerade to :1024-65535
        ip saddr 10.17.5.0/24 ip daddr != 10.17.5.0/24 ip protocol udp counter packets 17 bytes 1292 masquerade to :1024-65535
        ip saddr 10.17.5.0/24 ip daddr != 10.17.5.0/24 counter packets 0 bytes 0 masquerade
        
        # Paquetes multicast para 224.0.0.0/24 en la subred 10.17.3.0/24
        ip saddr 10.17.3.0/24 ip daddr 224.0.0.0/24 counter packets 0 bytes 0 return
        ip saddr 10.17.3.0/24 ip daddr 255.255.255.255 counter packets 0 bytes 0 return
        
        # Mascarada para tráfico TCP/UDP hacia otras subredes que no sean la propia
        ip saddr 10.17.3.0/24 ip daddr != 10.17.3.0/24 ip protocol tcp counter packets 0 bytes 0 masquerade to :1024-65535
        ip saddr 10.17.3.0/24 ip daddr != 10.17.3.0/24 ip protocol udp counter packets 35 bytes 2660 masquerade to :1024-65535
        ip saddr 10.17.3.0/24 ip daddr != 10.17.3.0/24 counter packets 0 bytes 0 masquerade
        
        # Paquetes multicast para 224.0.0.0/24 en la subred 192.168.122.0/24
        ip saddr 192.168.122.0/24 ip daddr 224.0.0.0/24 counter packets 0 bytes 0 return
        ip saddr 192.168.122.0/24 ip daddr 255.255.255.255 counter packets 0 bytes 0 return
        
        # Mascarada para tráfico TCP/UDP hacia otras subredes que no sean la propia
        ip saddr 192.168.122.0/24 ip daddr != 192.168.122.0/24 ip protocol tcp counter packets 0 bytes 0 masquerade to :1024-65535
        ip saddr 192.168.122.0/24 ip daddr != 192.168.122.0/24 ip protocol udp counter packets 0 bytes 0 masquerade to :1024-65535
        ip saddr 192.168.122.0/24 ip daddr != 192.168.122.0/24 counter packets 0 bytes 0 masquerade
    }

    # Cadena de post-routing para aplicar las reglas NAT definidas
    chain POSTROUTING {
        type nat hook postrouting priority srcnat; policy accept;
        counter packets 138 bytes 12137 jump LIBVIRT_PRT
    }
}

# Reglas de filtrado
table ip filter {
    chain input {
        type filter hook input priority filter; policy accept;

        # Aceptar tráfico UDP y TCP en el puerto 123 (NTP) y 3389 (RDP)
        udp dport 123 accept
        tcp dport 3389 accept
        
        # Aceptar solicitudes ICMP (ping)
        icmp type echo-request accept
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
        
        # Aceptar tráfico entre subredes específicas
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" accept
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" accept
        ip saddr 10.17.5.0/24 oifname "enp4s0f0" accept
        
        # Aceptar tráfico de retorno (conexiones establecidas)
        ip daddr 10.17.3.0/24 iifname "enp4s0f0" ct state established,related accept
        ip daddr 10.17.4.0/24 iifname "enp4s0f0" ct state established,related accept
        ip daddr 10.17.5.0/24 iifname "enp4s0f0" ct state established,related accept
        
        # Aceptar tráfico entre subredes
        ip saddr 10.17.3.0/24 ip daddr 10.17.4.0/24 accept
        ip saddr 10.17.3.0/24 ip daddr 10.17.5.0/24 accept
        ip saddr 10.17.4.0/24 ip daddr 10.17.3.0/24 accept
        ip saddr 10.17.4.0/24 ip daddr 10.17.5.0/24 accept
        ip saddr 10.17.5.0/24 ip daddr 10.17.3.0/24 accept
        ip saddr 10.17.5.0/24 ip daddr 10.17.4.0/24 accept
        
        # Aceptar tráfico relacionado con conexiones ya establecidas
        ct state established,related accept
    }

    # Cadena para procesamiento de paquetes en las interfaces de red de libvirt
    chain LIBVIRT_INP {
        iifname "virbr3" udp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr3" tcp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr3" udp dport 67 counter packets 14 bytes 4452 accept
        iifname "virbr3" tcp dport 67 counter packets 0 bytes 0 accept
        
        iifname "virbr1" udp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr1" tcp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr1" udp dport 67 counter packets 0 bytes 0 accept
        iifname "virbr1" tcp dport 67 counter packets 0 bytes 0 accept
        
        iifname "virbr2" udp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr2" tcp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr2" udp dport 67 counter packets 0 bytes 0 accept
        iifname "virbr2" tcp dport 67 counter packets 0 bytes 0 accept
        
        iifname "virbr0" udp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr0" tcp dport 53 counter packets 0 bytes 0 accept
        iifname "virbr0" udp dport 67 counter packets 0 bytes 0 accept
        iifname "virbr0" tcp dport 67 counter packets 0 bytes 0 accept
    }

    chain INPUT {
        type filter hook input priority filter; policy accept;
        counter packets 10275 bytes 5480636 jump LIBVIRT_INP
    }

    chain LIBVIRT_OUT {
        oifname "virbr3" udp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr3" tcp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr3" udp dport 68 counter packets 14 bytes 4608 accept
        oifname "virbr3" tcp dport 68 counter packets 0 bytes 0 accept
        
        oifname "virbr1" udp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr1" tcp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr1" udp dport 68 counter packets 0 bytes 0 accept
        oifname "virbr1" tcp dport 68 counter packets 0 bytes 0 accept
        
        oifname "virbr2" udp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr2" tcp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr2" udp dport 68 counter packets 0 bytes 0 accept
        oifname "virbr2" tcp dport 68 counter packets 0 bytes 0 accept
        
        oifname "virbr0" udp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr0" tcp dport 53 counter packets 0 bytes 0 accept
        oifname "virbr0" udp dport 68 counter packets 0 bytes 0 accept
        oifname "virbr0" tcp dport 68 counter packets 0 bytes 0 accept
    }

    chain OUTPUT {
        type filter hook output priority filter; policy accept;
        counter packets 16416 bytes 6567168 jump LIBVIRT_OUT
    }

    chain LIBVIRT_FWO {
        ip saddr 10.17.4.0/24 iifname "virbr3" counter packets 38 bytes 5526 accept
        iifname "virbr3" counter packets 0 bytes 0 reject
        ip saddr 10.17.5.0/24 iifname "virbr1" counter packets 17 bytes 1292 accept
        iifname "virbr1" counter packets 0 bytes 0 reject
        ip saddr 10.17.3.0/24 iifname "virbr2" counter packets 35 bytes 2660 accept
        iifname "virbr2" counter packets 0 bytes 0 reject
        ip saddr 192.168.122.0/24 iifname "virbr0" counter packets 0 bytes 0 accept
        iifname "virbr0" counter packets 0 bytes 0 reject
    }

    chain FORWARD {
        type filter hook forward priority filter; policy accept;
        counter packets 308 bytes 38063 jump LIBVIRT_FWX
        counter packets 308 bytes 38063 jump LIBVIRT_FWI
        counter packets 135 bytes 12898 jump LIBVIRT_FWO
    }

    chain LIBVIRT_FWI {
        ip daddr 10.17.4.0/24 oifname "virbr3" ct state related,established counter packets 36 bytes 14657 accept
        oifname "virbr3" counter packets 0 bytes 0 reject
        ip daddr 10.17.5.0/24 oifname "virbr1" ct state related,established counter packets 17 bytes 1292 accept
        oifname "virbr1" counter packets 0 bytes 0 reject
        ip daddr 10.17.3.0/24 oifname "virbr2" ct state related,established counter packets 34 bytes 2584 accept
        oifname "virbr2" counter packets 41 bytes 3212 reject
        ip daddr 192.168.122.0/24 oifname "virbr0" ct state related,established counter packets 0 bytes 0 accept
        oifname "virbr0" counter packets 0 bytes 0 reject
    }

    chain LIBVIRT_FWX {
        iifname "virbr3" oifname "virbr3" counter packets 0 bytes 0 accept
        iifname "virbr1" oifname "virbr1" counter packets 0 bytes 0 accept
        iifname "virbr2" oifname "virbr2" counter packets 0 bytes 0 accept
        iifname "virbr0" oifname "virbr0" counter packets 0 bytes 0 accept
    }
}
