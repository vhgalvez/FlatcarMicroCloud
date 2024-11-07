# Aplica configuración
sudo ovs-vsctl add-br br0
sudo ip addr add 192.168.0.25/24 dev br0
sudo ip link set br0 up

# Espera confirmación
echo "Presiona cualquier tecla para confirmar que la conexión funciona, o espera 60 segundos para revertir."
read -t 60

if [ $? -ne 0 ]; then
    echo "No hubo confirmación. Revertiendo..."
    sudo ip link set br0 down
    sudo ovs-vsctl del-br br0
    sudo systemctl restart NetworkManager
    echo "La configuración ha sido revertida."
fi
