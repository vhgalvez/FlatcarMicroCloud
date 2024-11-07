# Configuración de la Comunicación entre Redes NAT y el Servidor Bastion

La configuración descrita para permitir la comunicación entre las redes NAT y el servidor Bastion debe realizarse en la máquina virtual Bastion1, no en el host físico. Esto se debe a que Bastion1 es el nodo que se encargará de enrutar el tráfico entre las diferentes redes NAT y los demás nodos del clúster.

Aquí están los pasos detallados para asegurarse de que esta configuración se realiza correctamente en Bastion1:

## Configuración en la Máquina Virtual Bastion1

### Paso 1: Configuración del Reenvío de Paquetes en Bastion1

**Habilitar el reenvío de paquetes IPv4:**

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Agregar reglas de IPTables para permitir el tráfico entre interfaces:**

```bash
sudo iptables -A FORWARD -i br0 -o virbr0 -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```
**Paso 2: Configuración de Rutas Estáticas en Bastion1**

**Agregar rutas estáticas para cada red NAT:**

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
```

**Resumen de los Pasos en Bastion1**

1. **Habilitar el reenvío de paquetes IPv4:** Esto permitirá que Bastion1 reenvíe el tráfico entre sus interfaces de red.
2. **Configurar IPTables:** Las reglas de IPTables permiten el tráfico entre las interfaces `br0` y `virbr0`.
3. **Agregar rutas estáticas:** Estas rutas permiten a Bastion1 saber cómo alcanzar las redes `10.17.3.0/24` y `10.17.4.0/24` a través de la red `192.168.0.1.`

**Notas Adicionales**
- Asegúrate de que las interfaces `br0` y `virbr0` están correctamente configuradas en Bastion1.
- Verifica que las redes NAT estén correctamente configuradas en tu entorno de virtualización (KVM con Libvirt).