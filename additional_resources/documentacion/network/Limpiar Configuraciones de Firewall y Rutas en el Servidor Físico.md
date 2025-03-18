# Tutorial: Limpiar Configuraciones de Firewall y Rutas en el Servidor Físico

## Introducción

Este tutorial detalla los pasos para limpiar y restablecer las configuraciones de firewall y rutas en un servidor físico que ejecuta Linux. Esto puede ser útil en situaciones donde las reglas de firewall bloquean el tráfico de red o hay configuraciones incorrectas que afectan la conectividad.

---

## 1. Respaldar las Reglas Actuales

Antes de realizar cualquier cambio, es recomendable hacer un respaldo de las configuraciones actuales en caso de que necesitemos restaurarlas más tarde.

```bash
# Guardar reglas actuales de iptables
sudo iptables-save > ~/iptables-backup.rules

# Guardar reglas actuales de nftables
sudo nft list ruleset > ~/nftables-backup.rules
```

---

## 2. Flushear (Limpiar) Todas las Reglas de iptables
Ejecuta los siguientes comandos para eliminar todas las reglas y cadenas definidas en iptables:

```bash
# Limpiar todas las reglas de iptables

# Flush de reglas de filtrado
sudo iptables -F  
# Eliminar cadenas personalizadas
sudo iptables -X  
# Flush de reglas de NAT
sudo iptables -t nat -F  
# Eliminar cadenas de NAT
sudo iptables -t nat -X
# Flush de reglas de mangle
sudo iptables -t mangle -F  
# Eliminar cadenas de mangle
sudo iptables -t mangle -X  

```

```bash
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
```




## 3. Flushear (Limpiar) Todas las Reglas de nftables
Si el servidor usa **nftables**, debemos limpiarlo también:

```bash
sudo nft flush ruleset
```

Verifica que las reglas hayan sido eliminadas con:

```bash
sudo iptables -L -v -n
sudo nft list ruleset

sudo setenforce 0
sudo systemctl restart libvirtd
sudo systemctl restart NetworkManager

```

## 4. Deshabilitar iptables y nftables Temporalmente
Si deseas asegurarte de que el firewall no está bloqueando nada, desactiva los servicios temporalmente:

```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl stop nftables
sudo systemctl disable nftables
```

Esto garantizará que las reglas no se restauren automáticamente en el próximo reinicio.

---

## 5. Reiniciar el Servidor
Para asegurarte de que todos los cambios se aplican correctamente, reinicia el servidor físico:

```bash
sudo reboot
```



## Conclusión

Después de seguir estos pasos, tu servidor físico estará sin reglas de firewall activas. Esto permitirá verificar la conectividad sin bloqueos. Si necesitas aplicar nuevas reglas, puedes configurarlas manualmente o utilizar herramientas de gestión de firewall como `firewalld`, `nftables` o `iptables`.

Recuerda que dejar el servidor sin firewall lo expone a riesgos de seguridad, por lo que después de hacer las pruebas, es recomendable volver a activar y configurar reglas adecuadas.

**¡Listo! Ahora puedes probar la conectividad en tu red. 🚀**

