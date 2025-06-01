# Solución al Error de Conectividad en Redes Virtuales

## Contexto del Problema

En un entorno de virtualización usando KVM y libvirt, las máquinas virtuales (VMs) pueden estar conectadas a redes internas a través de interfaces virtuales y puentes (bridges) en el host de virtualización. El error de conectividad observado consiste en la incapacidad de las VMs en la red interna (por ejemplo, `10.17.x.x`) para acceder a otras redes internas, como `10.17.4.21`, mientras que el tráfico hacia Internet funciona correctamente.

## Diagnóstico Inicial

### Ping fallido entre redes internas (`10.17.x.x`)

Los pings a direcciones dentro de las subredes `10.17.4.x` y `10.17.3.x` no eran exitosos desde la máquina `k8s-api-lb` con IP `192.168.0.30`.

### Conectividad hacia Internet y `192.168.0.30` exitosa

Sin embargo, el tráfico hacia `8.8.8.8` y `192.168.0.30` funcionaba correctamente, lo que indica que la configuración de la red LAN e Internet estaba correcta, pero había problemas con la comunicación entre las redes internas virtualizadas.

## Solución Propuesta

La clave del problema reside en el enrutamiento entre redes internas virtuales (subredes `10.17.3.x` y `10.17.4.x`) y la falta de conocimiento de las rutas internas por parte del router físico `192.168.0.1`. A continuación, se detalla cómo se resuelve este problema:

### 1. Rutas de Red

En la configuración actual de la máquina `k8s-api-lb` (con IP `192.168.0.30`), las rutas a las subredes internas `10.17.3.0/24`, `10.17.4.0/24` y `10.17.5.0/24` deben ser manejadas por la dirección `192.168.0.40`, que es la IP del host físico que ejecuta las máquinas virtuales. Este es un comportamiento estándar en redes virtuales gestionadas por libvirt.

#### Rutas Correctas

```bash
10.17.3.0/24 via 192.168.0.40 dev eth0 proto static metric 10
10.17.4.0/24 via 192.168.0.40 dev eth0 proto static metric 10
10.17.5.0/24 via 192.168.0.40 dev eth0 proto static metric 10
```

Esto significa que cualquier tráfico dirigido a las redes internas `10.17.x.x` se enviará primero al host físico (`192.168.0.40`) para su posterior reenvío a través de los puentes virtuales creados por libvirt (por ejemplo, `virbr_kube02`, `virbr_kube03`).

### 2. Configuración de nftables

Las reglas de firewall con `nftables` deben permitir explícitamente el tráfico entre estas subredes internas para garantizar que las máquinas virtuales puedan comunicarse entre sí.

#### Ejemplo de reglas adicionales

```bash
# Permite el tráfico entre las subredes internas de KVM (10.17.x.x)
ip saddr 10.17.3.0/24 ip daddr 10.17.4.0/24 accept
ip saddr 10.17.4.0/24 ip daddr 10.17.3.0/24 accept
```

Estas reglas permiten el tráfico entre las subredes `10.17.3.0/24` y `10.17.4.0/24`, garantizando que las máquinas virtuales en estas redes puedan comunicarse entre sí.

### 3. Comportamiento del Router Físico (`192.168.0.1`)

El router físico `192.168.0.1` se encarga de la comunicación entre las redes externas (Internet) y las redes internas del host de virtualización. Sin embargo, este router físico no tiene conocimiento de las redes internas `10.17.x.x`. Por lo tanto, la máquina `k8s-api-lb` debe tener configuradas las rutas adecuadas para que el tráfico hacia `10.17.x.x` sea manejado por el host físico (`192.168.0.40`).

### 4. Revisión de las Rutas en el Host de Virtualización (`192.168.0.40`)

Asegúrate de que las máquinas virtuales tienen rutas configuradas correctamente hacia el gateway del host físico. En el caso de `k8s-api-lb`, esto implica la configuración de rutas hacia `192.168.0.40` para alcanzar las redes `10.17.x.x`.

## Pasos para Implementar la Solución

### Agregar rutas a las subredes internas en la máquina `k8s-api-lb`

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.40
sudo ip route add 10.17.4.0/24 via 192.168.0.40
sudo ip route add 10.17.5.0/24 via 192.168.0.40
```

### Configurar el firewall para permitir el tráfico entre las redes internas

Asegúrate de agregar reglas en `nftables` que permitan la comunicación entre las redes internas.

### Reiniciar las interfaces de red para aplicar los cambios

```bash
sudo systemctl restart network
```

### Verificar la conectividad

- Realiza pruebas de `ping` entre las máquinas de diferentes subredes.
- Ejecuta `traceroute` para verificar que el tráfico sigue la ruta esperada.

## Conclusión

Con esta solución, la máquina `k8s-api-lb` podrá comunicarse correctamente con las redes `10.17.3.x` y `10.17.4.x`, y el tráfico hacia Internet continuará siendo gestionado por el router físico `192.168.0.1`.