Paso 1: Crear un Playbook para Instalar Python en Flatcar Container Linux
Vamos a modificar el playbook para instalar Python utilizando un script específico que sea compatible con Flatcar.

1.1 Crear el Script de Instalación
Primero, vamos a crear un script que instale Python y pip en Flatcar. Guárdalo en /etc/ansible/install_python.sh.

bash
Copiar código
# /etc/ansible/install_python.sh

#!/bin/bash

if [ ! -f /usr/bin/python3 ]; then
  curl -O https://bootstrap.pypa.io/get-pip.py
  sudo bash get-pip.py
  sudo pip install ansible
fi
1.2 Crear el Playbook para Ejecutar el Script de Instalación
Luego, vamos a crear un playbook que ejecute este script en las máquinas virtuales.

yaml
Copiar código
# /etc/ansible/install_python.yml

---
- name: Instalar Python en las máquinas virtuales
  hosts: all
  become: yes
  gather_facts: no
  tasks:
    - name: Copiar script de instalación a las máquinas
      ansible.builtin.copy:
        src: /etc/ansible/install_python.sh
        dest: /tmp/install_python.sh
        mode: '0755'

    - name: Ejecutar script de instalación en las máquinas
      ansible.builtin.command: /tmp/install_python.sh
      changed_when: false
Paso 2: Actualizar el Playbook de Configuración de Rutas
Asegúrate de que el playbook de configuración de rutas esté correctamente configurado para usar el intérprete de Python y manejar el error de ruta existente de manera adecuada.

yaml
Copiar código
# /etc/ansible/configurar_rutas.yml

---
- name: Configurar rutas estáticas en las máquinas virtuales
  hosts: all
  become: yes
  vars:
    ansible_python_interpreter: /usr/bin/python3
  tasks:
    - name: Agregar ruta estática a la red bridge para kube_network_02
      ansible.builtin.command:
        cmd: ip route add 192.168.0.0/24 via {{ gateway }} || true
      when: inventory_hostname in groups['kube_network_02']
      vars:
        gateway: 10.17.3.1

    - name: Agregar ruta estática a la red bridge para kube_network_03
      ansible.builtin.command:
        cmd: ip route add 192.168.0.0/24 via {{ gateway }} || true
      when: inventory_hostname in groups['kube_network_03']
      vars:
        gateway: 10.17.4.1
Paso 3: Ejecutar el Playbook para Instalar Python
Ejecuta el playbook para instalar Python en todas las máquinas virtuales:
sudo chmod +x /etc/ansible/install_python.sh

bash
Copiar código
sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/install_python.yml
Paso 4: Ejecutar el Playbook para Configurar Rutas
Ejecuta el playbook para configurar las rutas en las máquinas virtuales:

bash
Copiar código
sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/configurar_rutas.yml
Resumen del Archivo Markdown Actualizado
markdown
Copiar código
# Configuración de Rutas Estáticas con Ansible

Este documento describe los pasos para configurar rutas estáticas en máquinas virtuales utilizando Ansible. Asumimos que Ansible se instalará en el servidor físico ProLiant DL380 G7, que tiene acceso a todas las máquinas virtuales.

## Paso 1: Instalar Ansible

En el servidor ProLiant DL380 G7, instala Ansible con los siguientes comandos:

```bash
sudo dnf install epel-release -y
sudo dnf install ansible -y
Paso 2: Configurar el Inventario de Ansible
Crea un archivo de inventario llamado hosts que contenga la información de las máquinas virtuales. Puedes crear este archivo en el directorio /etc/ansible o en un directorio de tu elección.

ini
Copiar código
# /etc/ansible/hosts

[kube_network_02]
freeipa1 ansible_host=10.17.3.11
load_balancer1 ansible_host=10.17.3.12
postgresql1 ansible_host=10.17.3.13

[kube_network_03]
bootstrap1 ansible_host=10.17.4.20
master1 ansible_host=10.17.4.21
master2 ansible_host=10.17.4.22
master3 ansible_host=10.17.4.23
worker1 ansible_host=10.17.4.24
worker2 ansible_host=10.17.4.25
worker3 ansible_host=10.17.4.26

[all:vars]
ansible_user=core
ansible_ssh_private_key_file=/root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
Paso 3: Dar Permisos a la Clave Privada
Asegúrate de que el archivo de clave privada tenga los permisos correctos:

bash
Copiar código
sudo chmod 600 /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift
Paso 4: Crear el Playbook para Instalar Python
Para que Ansible funcione correctamente, las máquinas virtuales necesitan tener Python instalado. Si estás utilizando Flatcar Container Linux (anteriormente CoreOS), deberás instalar Python en ellas.

4.1 Crear el Script de Instalación
Crea un script que instale Python y pip en Flatcar:

bash
Copiar código
# /etc/ansible/install_python.sh

#!/bin/bash

if [ ! -f /usr/bin/python3 ]; then
  curl -O https://bootstrap.pypa.io/get-pip.py
  sudo bash get-pip.py
  sudo pip install ansible
fi
4.2 Crear el Playbook para Ejecutar el Script de Instalación
Crea un archivo llamado install_python.yml con el siguiente contenido:

yaml
Copiar código
# /etc/ansible/install_python.yml

---
- name: Instalar Python en las máquinas virtuales
  hosts: all
  become: yes
  gather_facts: no
  tasks:
    - name: Copiar script de instalación a las máquinas
      ansible.builtin.copy:
        src: /etc/ansible/install_python.sh
        dest: /tmp/install_python.sh
        mode: '0755'

    - name: Ejecutar script de instalación en las máquinas
      ansible.builtin.command: /tmp/install_python.sh
      changed_when: false
Paso 5: Ejecutar el Playbook para Instalar Python
Ejecuta el playbook con el siguiente comando:

bash
Copiar código
sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/install_python.yml
Paso 6: Crear el Playbook de Ansible para Configurar Rutas
Crea un archivo llamado configurar_rutas.yml con el siguiente contenido:

yaml
Copiar código
# /etc/ansible/configurar_rutas.yml

---
- name: Configurar rutas estáticas en las máquinas virtuales
  hosts: all
  become: yes
  vars:
    ansible_python_interpreter: /usr/bin/python3
  tasks:
    - name: Agregar ruta estática a la red bridge para kube_network_02
      ansible.builtin.command:
        cmd: ip route add 192.168.0.0/24 via {{ gateway }} || true
      when: inventory_hostname in groups['kube_network_02']
      vars:
        gateway: 10.17.3.1

    - name: Agregar ruta estática a la red bridge para kube_network_03
      ansible.builtin.command:
        cmd: ip route add 192.168.0.0/24 via {{ gateway }} || true
      when: inventory_hostname in groups['kube_network_03']
      vars:
        gateway: 10.17.4.1
Paso 7: Ejecutar el Playbook para Configurar Rutas
Ejecuta el playbook con el siguiente comando:

bash
Copiar código
sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/configurar_rutas.yml
Explicación
Inventario de Ansible (hosts): Define los grupos de hosts (kube_network_02 y kube_network_03) y especifica las direcciones IP y las variables necesarias para la conexión SSH.
Playbook de Ansible para Instalar Python (install_python.yml): Copia y ejecuta un script para instalar Python y pip en las máquinas virtuales.
Playbook de Ansible para Configurar Rutas (configurar_rutas.yml): Define las tareas que se ejecutarán en cada host para agregar rutas estáticas.
Ejecución del Playbook: El comando ansible-playbook ejecuta los playbooks en los hosts definidos en el inventario, instalando Python y configurando las rutas estáticas como se especifica.
Notas Adicionales
Asegúrate de que las máquinas virtuales sean accesibles por SSH. Verifica que puedes conectarte a cada una de ellas usando la clave SSH especificada.
Verifica que el usuario y la clave SSH sean correctos. El usuario core y la clave privada /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift deben ser correctos y tener permisos adecuados.
Si encuentras problemas de conectividad o permisos, verifica los logs de Ansible y ajusta las configuraciones según sea necesario.
Esta configuración de Ansible es más escalable y eficiente, ya que permite aplicar configuraciones en múltiples máquinas virtuales en paralelo, asegurando consistencia y ahorrando tiempo.

bash
Copiar código

### Ejecución y Verificación

1. **Instala Python en las máquinas virtuales:**
   ```bash
   sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/install_python.yml
Configura las rutas estáticas en las máquinas virtuales:
bash
Copiar código
sudo ansible-playbook -i /etc/ansible/hosts /etc/ansible/configurar_rutas.yml
Siguiendo estos pasos, deberías poder instalar Python y configurar las rutas estáticas en tus máquinas virtuales utilizando Ansible.


sudo ansible-playbook -i /etc/ansible/ansible-network-setup-cluster-openshift/hosts /etc/ansible/ansible-network-setup-cluster-openshift/install_python.yml
