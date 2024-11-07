
# kvm_cluster_terraform

Este documento proporciona instrucciones detalladas para la gestión y solución de problemas en un clúster de KVM gestionado con Terraform.

## Eliminar las VMs

Para eliminar las máquinas virtuales, debes hacer ejecutable el script `eliminar_vms.sh` y luego ejecutarlo:

```bash
chmod +x eliminar_vms.sh
./eliminar_vms.sh
```


# Gestión de Memoria

Para permitir el sobrecompromiso de memoria, que puede ser necesario en entornos de virtualización densa, ajusta el parámetro `vm.overcommit_memory`:

```bash
sysctl vm.overcommit_memory=1
```

#  Administración del Servicio Libvirt
Verificar el Estado del Servicio Libvirt
Para comprobar el estado del servicio Libvirt y asegurarte de que está activo y funcionando, usa:

```bash
sudo systemctl status libvirtd
```

Reiniciar el Servicio Libvirt

Un reinicio puede solucionar problemas transitorios con el servicio Libvirt:

bash
Copy code
sudo systemctl restart libvirtd
Revisar la Configuración de Registro (Logging)
Es importante asegurarse de que la configuración de registros de Libvirt esté adecuada para capturar detalles necesarios. Revisa y ajusta la configuración en /etc/libvirt/libvirtd.conf:

conf
Copy code
log_level = 3
log_outputs = "1:file:/var/log/libvirt/libvirtd.log"
Después de hacer cambios, reinicia el servicio para que los ajustes tengan efecto.

Verificar Logs Alternativos
Si los registros del servicio Libvirt no están disponibles a través de journalctl, revisa directamente los archivos de registro:

bash
Copy code
sudo cat /var/log/libvirt/libvirtd.log
Buscar Errores en Logs del Sistema
Además de los logs de Libvirt, revisa los logs generales del sistema para cualquier mensaje relacionado con Libvirt o QEMU:

bash
Copy code
sudo dmesg | grep -i qemu
sudo grep -i qemu /var/log/syslog  # En sistemas que usen syslog
Aumentar el Límite del Espacio de Direcciones Físicas
Para resolver problemas con el límite del espacio de direcciones físicas en QEMU, especialmente cuando se encuentra demasiado bajo, realiza los siguientes pasos:

Abre el archivo /etc/sysctl.conf con un editor de texto como nano:
bash
Copy code
sudo nano /etc/sysctl.conf
Agrega la siguiente línea al final del archivo para aumentar el límite:
conf
Copy code
vm.max_map_count = 262144
Guarda los cambios y cierra el archivo. Verifica que la línea se haya agregado correctamente:
bash
Copy code
sudo cat /etc/sysctl.conf
Aplica los cambios:
css
Copy code
sudo sysctl -p
Si el problema persiste y se necesita un límite aún mayor, considera ajustar vm.max_map_count a un valor más alto, como 655300, para resolver definitivamente el problema.

Comandos Útiles
Ver ayuda de CPU con QEMU:
bash
Copy code
/usr/libexec/qemu-kvm -cpu help



# kvm_cluster_terraform
 kvm_cluster_terraform


# Eliminar las VMs
chmod +x eliminar_vms.sh.

./eliminar_vms.sh


./eliminar_vms.sh

sysctl vm.overcommit_memory

Si es necesario, cambia el valor a 1 para permitir el sobrecompromiso de memoria2:

sysctl vm.overcommit_memory=1


Verificar el Estado del Servicio Libvirt:
Comprueba el estado del servicio para asegurarte de que está activo y corriendo:
bash
Copy code
sudo systemctl status libvirtd
Reiniciar el Servicio Libvirt:
A veces, un simple reinicio del servicio puede solucionar problemas transitorios:
bash
Copy code
sudo systemctl restart libvirtd
Revisar la Configuración de Registro (Logging):
Verifica si la configuración de libvirt está ajustada para registrar los detalles necesarios. Puedes revisar el archivo de configuración de libvirt (usualmente ubicado en /etc/libvirt/libvirtd.conf) y buscar las siguientes líneas:
conf
Copy code
log_level = 3
log_outputs = "1:file:/var/log/libvirt/libvirtd.log"
Asegúrate de que el registro esté activado y configurado para escribir en un archivo. Si haces cambios, reinicia el servicio para aplicarlos.
Verificar Logs Alternativos:
Si los registros del servicio no están disponibles a través de journalctl, intenta revisar directamente los archivos de registro que podrían estar en /var/log/libvirt/ o en la ubicación especificada en la configuración:
bash
Copy code
sudo cat /var/log/libvirt/libvirtd.log
Buscar Errores en Logs del Sistema:
Además de los logs de libvirt, revisa los logs generales del sistema para cualquier mensaje relacionado con libvirt o QEMU:
bash
Copy code
sudo dmesg | grep -i qemu
sudo grep -i qemu /var/log/syslog  # En sistemas que usen syslog


/usr/libexec/qemu-kvm -cpu help


Parece que has abierto el archivo /etc/sysctl.conf con el comando nano, pero no has agregado la línea necesaria para aumentar el límite del espacio de direcciones físicas.

Aquí tienes los pasos nuevamente:

Abre el archivo /etc/sysctl.conf con el editor de texto nano:
bash
Copy code
sudo nano /etc/sysctl.conf
Agrega la siguiente línea al final del archivo:
Copy code
vm.max_map_count = 262144
Esto aumentará el límite del espacio de direcciones físicas.
Guarda los cambios y cierra el archivo.
Una vez hecho esto, puedes verificar que la línea se haya agregado correctamente ejecutando:

bash
Copy code
sudo cat /etc/sysctl.conf
Si la línea está presente, procede a aplicar los cambios ejecutando:

css
Copy code
sudo sysctl -p


El error que estás experimentando indica que el límite del espacio de direcciones físicas es demasiado bajo para que QEMU funcione correctamente. Parece que ya has abierto el archivo /etc/sysctl.conf y has agregado la línea vm.max_map_count = 262144.

Sin embargo, el problema persiste. Parece que la advertencia "Address space limit 0xffffffffff < 0x2087fffffff phys-bits too low (40)" indica que el límite del espacio de direcciones físicas aún es insuficiente.

Para resolver esto, necesitas aumentar el límite del espacio de direcciones físicas aún más. Puedes intentar agregar la siguiente línea al final del archivo /etc/sysctl.conf:

Copy code
vm.max_map_count = 655300
Esta configuración debería aumentar significativamente el límite del espacio de direcciones físicas y resolver el error que estás experimentando.

Después de hacer este cambio, guarda el archivo y recarga la configuración del kernel ejecutando:

css
Copy code
sudo sysctl -p
Una vez hecho esto, intenta ejecutar nuevamente tu proceso de creación de máquinas virtuales con QEMU para ver si el problema se ha resuelto.