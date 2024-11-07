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
