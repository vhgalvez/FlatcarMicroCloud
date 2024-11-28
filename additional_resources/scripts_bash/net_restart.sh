#!/bin/bash

echo "Reiniciando los servicios..."

# Reiniciar servicios básicos
sudo systemctl restart libvirtd && echo "libvirtd reiniciado con éxito."
sleep 5

sudo systemctl restart iptables && echo "iptables reiniciado con éxito."
sleep 5

sudo systemctl restart NetworkManager && echo "NetworkManager reiniciado con éxito."
sleep 5

# Reiniciar y habilitar firewalld
sudo systemctl enable firewalld
sudo systemctl restart firewalld && echo "firewalld reiniciado y habilitado con éxito."
sudo firewall-cmd --reload && echo "firewalld recargado con éxito."
sleep 5

# habilitar iptables
sudo systemctl start iptables && echo "iptables reiniciado con éxito."
sleep 5

echo "Todos los servicios han sido reiniciados con éxito."