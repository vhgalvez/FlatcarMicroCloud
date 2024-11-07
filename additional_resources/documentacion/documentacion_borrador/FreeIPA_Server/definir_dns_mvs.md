Preparar el script:

Crea un archivo de script en tu servidor de administración con el siguiente contenido:

bash
Copiar código
#!/bin/bash

# Lista de IPs de las máquinas virtuales
IPS=("10.17.3.11" "10.17.3.12" "10.17.3.13" "10.17.4.20" "10.17.4.21" "10.17.4.22" "10.17.4.23" "10.17.4.24" "10.17.4.25" "10.17.4.26")

# Usuario de SSH
USER="core"

# Ruta a la clave privada
SSH_KEY="/root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift"

# Archivo de configuración de NetworkManager
NM_CONF_CONTENT="[main]\ndns=none\n\n[global-dns-domain-*]\nservers=10.17.3.11\nsearches=localcefas.com\n"

# Configuración de resolv.conf
RESOLV_CONF_CONTENT="nameserver 10.17.3.11\nsearch localcefas.com\n"

# Aplicar configuración en cada máquina
for IP in "${IPS[@]}"
do
  echo "Configurando $IP"
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$IP "echo -e '$NM_CONF_CONTENT' | sudo tee /etc/NetworkManager/conf.d/dns.conf"
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$IP "sudo sed -i '/\[main\]/a rc-manager=unmanaged' /etc/NetworkManager/NetworkManager.conf"
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$IP "echo -e '$RESOLV_CONF_CONTENT' | sudo tee /etc/resolv.conf"
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$IP "sudo chattr +i /etc/resolv.conf"
  ssh -i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USER@$IP "sudo systemctl restart NetworkManager"
  echo "Configuración completada en $IP"
done
Guarda este script, por ejemplo, como update_dns_config.sh.

Dar permisos de ejecución al script:

bash
Copiar código
chmod +x update_dns_config.sh
Ejecutar el script:

bash
Copiar código
./update_dns_config.sh
Detalles del script:
IPS: Lista de direcciones IP de las máquinas virtuales que se deben configurar.
USER: El nombre de usuario para conectarse a las máquinas virtuales.
SSH_KEY: Ruta a la clave privada SSH utilizada para la autenticación.
NM_CONF_CONTENT: Contenido del archivo de configuración dns.conf para NetworkManager.
RESOLV_CONF_CONTENT: Contenido del archivo /etc/resolv.conf.
SSH opciones: Las opciones -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null se utilizan para evitar problemas con las claves de host conocidas.
Este script se conecta a cada máquina virtual, aplica la configuración necesaria para NetworkManager y el archivo resolv.conf, y luego reinicia el servicio NetworkManager para aplicar los cambios. La configuración de DNS será persistente y correcta en todas las máquinas virtuales.