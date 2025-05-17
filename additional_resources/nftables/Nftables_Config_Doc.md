# Configuración de nftables para conectividad y seguridad en entornos virtualizados

Este documento describe una configuración funcional y optimizada para el firewall `nftables`, con el objetivo de:

- ✅ Permitir conectividad a Internet desde las Máquinas Virtuales (VMs) en las subredes `10.17.X.X`
- ✅ Asegurar la comunicación entre subredes internas (`virbr1`, `virbr2`, `virbr3`)
- ✅ Autorizar servicios básicos como `ping`, `XRDP`, `NTP` y conexiones ya establecidas
- ✅ Aplicar una política segura por defecto: `FORWARD` con `policy drop`

---

## Archivo de configuración `/etc/sysconfig/nftables.conf`

```nft
#!/usr/sbin/nft -f

flush ruleset

# === Tabla NAT para salida a Internet ===
table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100; policy accept;

        ip saddr 10.17.5.0/24 oifname "enp4s0f0" masquerade
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" masquerade
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" masquerade
    }
}

# === Tabla de filtrado ===
table ip filter {
    chain input {
        type filter hook input priority 0; policy accept;

        # Servicios básicos
        udp dport 123 accept         # NTP
        tcp dport 3389 accept        # XRDP
        icmp type echo-request accept  # Ping
    }

    chain forward {
        type filter hook forward priority 0; policy drop;

        # 🟢 Salida a Internet desde VMs
        ip saddr 10.17.3.0/24 oifname "enp4s0f0" accept
        ip saddr 10.17.4.0/24 oifname "enp4s0f0" accept
        ip saddr 10.17.5.0/24 oifname "enp4s0f0" accept

        # 🟢 Respuestas desde Internet hacia las VMs
        ip daddr 10.17.3.0/24 iifname "enp4s0f0" ct state established,related accept
        ip daddr 10.17.4.0/24 iifname "enp4s0f0" ct state established,related accept
        ip daddr 10.17.5.0/24 iifname "enp4s0f0" ct state established,related accept

        # 🔄 Tráfico entre subredes internas
        ip saddr 10.17.3.0/24 ip daddr 10.17.4.0/24 accept
        ip saddr 10.17.3.0/24 ip daddr 10.17.5.0/24 accept
        ip saddr 10.17.4.0/24 ip daddr 10.17.3.0/24 accept
        ip saddr 10.17.4.0/24 ip daddr 10.17.5.0/24 accept
        ip saddr 10.17.5.0/24 ip daddr 10.17.3.0/24 accept
        ip saddr 10.17.5.0/24 ip daddr 10.17.4.0/24 accept

        # 🔁 Permitir conexiones ya establecidas
        ct state established,related accept
    }
}
```

---

## Activar el reenvío de paquetes IPv4

Es necesario habilitar el reenvío de paquetes en el kernel para que las VMs puedan enrutar hacia Internet:

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

## Aplicar la configuración y habilitar el servicio

1. **Cargar las reglas**:

   ```bash
   sudo nft -f /etc/sysconfig/nftables.conf
   sudo nft list ruleset | sudo tee /etc/sysconfig/nftables.conf
   ```

2. **Habilitar el servicio `nftables` para que se cargue al inicio**:

   ```bash
   sudo systemctl daemon-reexec
   sudo systemctl enable --now nftables
   sudo systemctl restart nftables
   sudo systemctl status nftables
   ```

3. **Validar la configuración**:

   ```bash
   sudo nft list ruleset
   ```

---

## Resultado esperado

- Las VMs en `10.17.3.0/24`, `10.17.4.0/24`, `10.17.5.0/24` deben tener acceso a Internet.
- Las VMs deben poder comunicarse entre ellas.
- Se permiten servicios como:
  - `ping`
  - `ntpd` (puerto UDP 123)
  - `xrdp` (puerto TCP 3389)
- El tráfico `FORWARD` no autorizado queda bloqueado por defecto (`policy drop`).
- El tráfico de respuesta y conexiones establecidas funcionan correctamente.

---

## Verificar compatibilidad con iptables-nft

1. **Confirmar que iptables usa nftables como backend**:

   ```bash
   sudo update-alternatives --display iptables
   ```

   Si no está configurado, ajustarlo con:

   ```bash
   sudo update-alternatives --set iptables /usr/sbin/iptables-nft
   sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-nft
   ```

2. **Actualizar y configurar firewalld**:

   ```bash
   sudo dnf update -y
   sudo dnf install libvirt firewalld nftables iptables-nft -y
   sudo nano /etc/firewalld/firewalld.conf
   ```

   Cambiar la línea `#NftablesTableOwner=yes` a:

   ```ini
   NftablesTableOwner=no
   ```

   Reiniciar firewalld:

   ```bash
   sudo systemctl restart firewalld
   ```

3. **Habilitar módulos del kernel para NAT**:

   ```bash
   echo -e "options nf_conntrack ip_conntrack_helper=1\noptions nf_nat_ftp nf_nat=1" | sudo tee /etc/modprobe.d/libvirt-nft.conf
   sudo modprobe -r nf_conntrack nf_nat_ftp
   sudo modprobe nf_conntrack nf_nat_ftp
   ```

4. **Reiniciar servicios**:

   ```bash
   sudo systemctl restart libvirtd firewalld
   ```

5. **Verificar reglas de nftables**:

   ```bash
   sudo nft list ruleset | grep -i virbr
   ```

   Deberías ver algo como:

   ```nft
   chain nat_POSTROUTING {
     oifname "virbr0" masquerade
   }
   ```

---

## Recomendaciones de configuración

- **Backend de iptables**: Utilizar `iptables-nft` es adecuado y compatible con `nftables`.
- **firewalld y nftables**: Si deseas una configuración más sencilla y directa, puedes desactivar `firewalld` y gestionar las reglas directamente con `nftables`.
- **libvirt y QEMU**: Funcionan correctamente con `nftables` y `iptables-nft`. Asegúrate de que los servicios estén habilitados y en funcionamiento.

---

## Recursos adicionales

- [libvirt-nft-ruler](https://github.com/clemensschlipfinger/libvirt-nft-ruler)

sudo nft add rule inet nat postrouting ip saddr 10.17.3.0/24 ip daddr 10.42.0.0/16 masquerade


worker1
sudo nft add rule inet nat postrouting ip daddr 10.17.3.0/24 ip saddr 10.42.0.0/16 masquerade


sudo nft add rule inet nat postrouting ip saddr 10.17.3.0/24 ip daddr 10.42.0.0/16 masquerade


sudo nft add rule inet filter input ip saddr 10.17.3.0/24 tcp dport 8080 accept

sudo nft list ruleset | grep 8080


