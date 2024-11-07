#!/bin/bash

# Define un arreglo con los nombres de las máquinas virtuales
vms=("bastion1" "bootstrap1" "elasticsearch1" "freeipa1" "kibana1" "load_balancer1" "master1" "master2" "master3" "nfs1" "postgresql1" "worker1" "worker2" "worker3")

# Itera sobre el arreglo y elimina las máquinas virtuales
for vm in "${vms[@]}"
do
    sudo virsh undefine "$vm"
done
