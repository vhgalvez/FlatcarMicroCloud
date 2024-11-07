#!/bin/bash

# Mostrar configuración de iptables
echo "### iptables rules ###"
sudo iptables-save

# Mostrar configuración de interfaces de red
echo "### Network interfaces ###"
ip addr

# Mostrar rutas IP
echo "### IP routes ###"
ip route

# Mostrar información del sistema
echo "### System information ###"
hostnamectl

# Mostrar configuración de todas las zonas de firewalld
echo "### firewalld configuration ###"
sudo firewall-cmd --list-all-zones