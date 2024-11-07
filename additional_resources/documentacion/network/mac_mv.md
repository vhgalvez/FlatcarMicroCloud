Paso a paso para obtener las direcciones MAC de todas las máquinas virtuales
Crear un script de shell:
Abre un editor de texto en tu sistema y crea un nuevo archivo, por ejemplo, get_mac_addresses.sh.

Escribe el script:
Inserta el siguiente contenido en el archivo get_mac_addresses.sh:

bash
Copiar código
#!/bin/bash

# Lista de nombres de máquinas virtuales
VM_NAMES=("bastion1.cefaslocalserver.com" "freeipa1" "load_balancer1" "postgresql1" "bootstrap1" "master1" "master2" "master3" "worker1" "worker2" "worker3")

# Recorre cada nombre de máquina virtual
for vm_name in "${VM_NAMES[@]}"
do
    echo "Máquina virtual: $vm_name"
    sudo virsh domiflist $vm_name | grep -E "^[[:space:]]+vnet[0-9]+[[:space:]]+" | awk '{ print "  Interfaz:", $1, "MAC:", $5 }'
    echo
done
Guardar y cerrar el archivo:
Guarda el archivo get_mac_addresses.sh y ciérralo.

Dar permisos de ejecución:
Haz que el script sea ejecutable con el siguiente comando:

bash
Copiar código
chmod +x get_mac_addresses.sh
Ejecutar el script:
Ejecuta el script para obtener las direcciones MAC de todas las máquinas virtuales:

bash
Copiar código
./get_mac_addresses.sh
Explicación del script:
VM_NAMES: Es un arreglo que contiene los nombres de todas las máquinas virtuales para las cuales quieres obtener las direcciones MAC.
El script usa virsh domiflist <nombre_de_la_maquina_virtual> para cada máquina virtual en la lista VM_NAMES.
grep -E "^[[:space:]]+vnet[0-9]+[[:space:]]+" filtra solo las líneas que contienen información de interfaces de red (vnetX).
awk '{ print " Interfaz:", $1, "MAC:", $5 }' formatea la salida para mostrar el nombre de la interfaz y la dirección MAC correspondiente.
Notas adicionales:
Asegúrate de ejecutar el script con permisos de superusuario usando sudo si es necesario, especialmente para el comando virsh.
El script asume que las máquinas virtuales están en ejecución (--all no es necesario para este script porque estamos usando nombres explícitos de máquinas virtuales).
Con este script, podrás obtener rápidamente todas las direcciones MAC de tus máquinas virtuales en KVM, facilitando así la configuración de tu entorno de cluster de OpenShift.