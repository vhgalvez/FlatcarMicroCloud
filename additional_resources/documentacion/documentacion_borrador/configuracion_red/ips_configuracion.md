 # Pasos Adicionales para Configuración Manual

Si tienes configuraciones manuales que deben aplicarse después de recrear las máquinas, como la configuración de rutas IP o reglas de firewall que no están en tus archivos de Terraform, deberás volver a aplicar estas configuraciones manualmente.

Por ejemplo, para configurar rutas IP manualmente, usa comandos como:

```bash
# En bastion1
sudo ip route add 10.17.3.0/24 via 192.168.0.42
sudo ip route add 10.17.4.0/24 via 192.168.0.42
```


## En bootstrap1

```bash
sudo ip route add 10.17.4.0/24 via 192.168.0.42
```

## En freeipa1

```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.42
```

5. Verificar Conectividad
   
   
6. Después de recrear las máquinas, verifica la conectividad de la red y el estado de las configuraciones:

Ping entre las máquinas: Verifica que las máquinas puedan comunicarse entre sí usando ping.
Verificar rutas: Usa ip route para verificar que las rutas están configuradas correctamente.
Verificar reglas de firewall: Usa firewalld o iptables según corresponda para asegurarte de que las reglas de firewall están aplicadas correctamente.
Resumen de Pasos

Destruir recursos:

```bash
sudo terraform destroy
```

Recrear recursos:

```bash
sudo terraform apply
```

Reaplicar configuraciones manuales (si es necesario).

Verificar la conectividad y configuraciones.

Con estos pasos, deberías poder destruir y recrear tus máquinas virtuales y asegurarte de que la red funcione correctamente.