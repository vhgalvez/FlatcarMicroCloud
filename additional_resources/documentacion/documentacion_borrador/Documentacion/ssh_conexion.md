chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
ssh -i path/to/private_key core@<IP_VM>

chmod 600 /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift


ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift <usuario>@<servidor_ip>

ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift core@10.17.3.21 -p 22


> /root/.ssh/known_hosts
rm /root/.ssh/known_hosts


ssh -o StrictHostKeyChecking=no -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift core@10.17.3.21
sudo chmod 600 /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift


ssh 192.168.122.46

ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift serra@192.168.122.46 -p 22

sudo ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift serra@192.168.122.249 -p 22

sudo ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift core@192.168.122.10 -p 22


sudo ssh -v -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift core@192.168.0.27 -p 22





- Generación de Contraseña Hash:
La contraseña para el usuario core debe estar en formato hash.
Puedes generar un hash de contraseña usando el comando mkpasswd --method=SHA-512. El ejemplo anterior usa un hash ficticio.


[victory@server ~]$ openssl passwd -6
Password:
Verifying - Password:
$6$OxqQVs2ixPjpI.bG$XGK8RJ/eBh0U1U7BLgMCcIlhJ2IhEyUU8RiO61dxk6r81YFGET4oqauuSQm76yjiXl8WPn3aPBIK8gBBFiyGP1
[victory@server ~]$



Para instalar correctamente la herramienta mkpasswd en Rocky Linux, es necesario asegurarse de que el repositorio adecuado está habilitado, ya que parece que esta herramienta está en el repositorio de desarrollo (devel). Aquí te muestro cómo instalarlo paso a paso, incluyendo la activación del repositorio si es necesario.

Instalación de mkpasswd en Rocky Linux
Habilitar el repositorio de desarrollo (si es necesario):
Asegúrate de que el repositorio devel está habilitado en tu sistema. Si no estás seguro de cómo hacerlo, puedes buscar en la documentación de Rocky Linux o usar el siguiente comando que podría ser aplicable:

bash
Copy code
sudo dnf config-manager --set-enabled devel
Si el comando anterior no funciona y no sabes cómo habilitar el repositorio, una búsqueda detallada en la documentación de Rocky Linux o consultar en foros específicos puede ser útil.

Instalar el paquete mkpasswd:
Una vez que el repositorio está habilitado, puedes instalar mkpasswd utilizando dnf, el gestor de paquetes de Rocky Linux:

bash
Copy code
sudo dnf install mkpasswd
Generación de un Hash de Contraseña con mkpasswd
Después de instalar mkpasswd, puedes generar un hash de contraseña de la siguiente manera:

bash
Copy code
mkpasswd --method=sha-512
Cuando ejecutes este comando, se te pedirá que ingreses la contraseña para la cual deseas generar el hash. Este hash puede ser utilizado en tus configuraciones de Cloud-init para establecer contraseñas de manera segura.