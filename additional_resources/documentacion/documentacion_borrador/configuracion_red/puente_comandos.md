
### Notas Técnicas
- `br0` es una interfaz puente que conecta `enp3s0f0` y `vnet0`.
- Los puentes `virbr0` y `virbr1` son utilizados para redes virtuales, conectando varias interfaces virtuales (`vnetX`).
- La interfaz `br0` tiene asignada dos direcciones IP (`192.168.0.28` y `192.168.0.21`).

### Comandos Utilizados
- `ifconfig` y `ip addr` para mostrar las interfaces de red.
- `ip link show type bridge` para mostrar los puentes de red.
- `brctl show` para listar los puentes y sus interfaces conectadas.
- `nmcli connection show` para listar las conexiones administradas por NetworkManager.

Estas herramientas y comandos ayudan a verificar y gestionar la configuración de red, incluyendo puentes y interfaces asociadas.
