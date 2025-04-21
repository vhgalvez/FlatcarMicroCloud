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

1. Cargar las reglas:

```bash
sudo nft -f /etc/sysconfig/nftables.conf
```

sudo nft list ruleset | sudo tee /etc/sysconfig/nftables.conf




2. Habilitar el servicio `nftables` para que se cargue al inicio:

```bash
sudo systemctl daemon-reexec
sudo systemctl enable --now nftables
sudo systemctl start nftables
sudo systemctl restart nftables
sudo systemctl status nftables
```
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

Este setup asegura que tu entorno de virtualización con subredes internas y salida a Internet tenga una política de seguridad clara, precisa y compatible con Kubernetes y otros servicios distribuidos internos.



✅ OBJETIVO
Configurar Libvirt + nftables en Rocky Linux 9.5 usando iptables-nft (por defecto en RHEL9+), asegurando:

Que Libvirt cree redes NAT sin errores.

Que nftables funcione como firewall.

Que NO necesites iptables-legacy.

🧱 PASO A PASO
1. 🔍 Verifica que estás usando iptables-nft
bash
Copiar
Editar
sudo update-alternatives --display iptables
Debe decir algo como:

bash
Copiar
Editar
link currently points to /usr/sbin/iptables-nft
Si NO, cámbialo con:

bash
Copiar
Editar
sudo update-alternatives --set iptables /usr/sbin/iptables-nft
sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-nft
2. 🧰 Asegúrate de tener todo actualizado
bash
Copiar
Editar
sudo dnf update -y
sudo dnf install libvirt firewalld nftables iptables-nft -y
3. 🔥 Configura firewalld para trabajar con nftables
Editar el archivo de configuración:

bash
Copiar
Editar
sudo nano /etc/firewalld/firewalld.conf
Busca la línea:

shell
Copiar
Editar
#NftablesTableOwner=yes
Y cámbiala a:

ini
Copiar
Editar
NftablesTableOwner=no
Esto permite que Libvirt inserte sus reglas directamente en nftables.

Reinicia firewalld:

bash
Copiar
Editar
sudo systemctl restart firewalld
4. 🧠 Asegúrate de que el kernel soporte NAT
Habilita módulos necesarios:

bash
Copiar
Editar
echo -e "options nf_conntrack ip_conntrack_helper=1\noptions nf_nat_ftp nf_nat=1" | sudo tee /etc/modprobe.d/libvirt-nft.conf
Cárgalos:

bash
Copiar
Editar
sudo modprobe -r nf_conntrack nf_nat_ftp
sudo modprobe nf_conntrack nf_nat_ftp
5. 🚀 Reinicia Libvirt y Firewalld
bash
Copiar
Editar
sudo systemctl restart libvirtd firewalld
6. 🌐 Verifica que virbr0 se está creando bien
bash
Copiar
Editar
sudo virsh net-list --all
Si no está activa:

bash
Copiar
Editar
sudo virsh net-start default
sudo virsh net-autostart default
También puedes probar con una red NAT personalizada.

7. 🔎 Verifica que Libvirt usa nftables correctamente
bash
Copiar
Editar
sudo nft list ruleset | grep -i virbr
Deberías ver algo como:

nginx
Copiar
Editar
chain nat_POSTROUTING {
  oifname "virbr0" masquerade
}
✅ CONCLUSIÓN
Libvirt funciona bien con iptables-nft y nftables en Rocky Linux 9.5, si:

Se ajusta firewalld para permitir que Libvirt modifique nftables.

Se evita usar iptables-legacy (desaprobado en RHEL9).

Se reinician correctamente los servicios.


Respuesta concisa y técnica:

Sí, en Rocky Linux 9.5 necesitas que estos 3 componentes trabajen juntos para Libvirt/QEMU:

firewalld + nftables + iptables-nft son requeridos en conjunto porque:

nftables es el backend real del firewall (reemplazo moderno de iptables)

iptables-nft provee compatibilidad para aplicaciones que aún usan comandos iptables (como Libvirt)

firewalld actúa como frontend unificado que gestiona ambos sistemas

[QEMU] ← (API) → [Libvirt] ← (iptables-nft) → [nftables]
                   ↑
                   ↓
               [firewalld]


​Para que libvirt y QEMU funcionen correctamente en Rocky Linux 9.5, es recomendable utilizar iptables-nft como backend, ya que es el predeterminado en esta versión y es compatible con nftables. Sin embargo, si prefieres una configuración más directa y controlada, puedes optar por utilizar únicamente nftables sin firewalld.​

🔧 Recomendaciones de configuración
Backend de iptables: Utilizar iptables-nft es adecuado y compatible con nftables.​

firewalld y nftables: firewalld es una capa de abstracción sobre nftables y iptables. Si deseas una configuración más sencilla y directa, puedes desactivar firewalld y gestionar las reglas directamente con nftables.​

libvirt y QEMU: Funcionan correctamente con nftables y iptables-nft. Asegúrate de que los servicios estén habilitados y en funcionamiento.



https://github.com/clemensschlipfinger/libvirt-nft-ruler


sudo systemctl restart nftables
sudo nft list ruleset


✅ Para aplicar los cambios:
bash
Copiar
Editar
sudo systemctl restart nftables
Y luego valida que se haya cargado correctamente:

bash
Copiar
Editar
sudo nft list ruleset
