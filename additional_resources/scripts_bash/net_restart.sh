#!/bin/bash

# Reiniciar el servicio libvirtd
echo "Reiniciando el servicio libvirtd..."
sudo systemctl restart libvirtd
sleep 5  # Esperar 5 segundos para asegurarse de que el servicio se reinicie completamente

# Reiniciar el servicio iptables
echo "Reiniciando el servicio iptables..."
sudo systemctl restart iptables
sleep 5  # Esperar 5 segundos para asegurarse de que el servicio se reinicie completamente

# Reiniciar el servicio NetworkManager
echo "Reiniciando el servicio NetworkManager..."
sudo systemctl restart NetworkManager
sleep 5  # Esperar 5 segundos para asegurarse de que el servicio se reinicie completamente

echo "Todos los servicios han sido reiniciados con éxito."