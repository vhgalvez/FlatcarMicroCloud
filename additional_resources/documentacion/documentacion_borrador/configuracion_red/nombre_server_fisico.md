Para cambiar correctamente el nombre del servidor físico a physical1.cefaslocalserver.com, sigue estos pasos:

Editar el archivo /etc/hostname:

bash
Copiar código
sudo nano /etc/hostname
Cambia el contenido a:

plaintext
Copiar código
physical1.cefaslocalserver.com
Editar el archivo /etc/hosts:

bash
Copiar código
sudo nano /etc/hosts
Actualiza la línea correspondiente para reflejar el nuevo nombre:

plaintext
Copiar código
127.0.1.1   physical1.cefaslocalserver.com   physical1
Reiniciar el servidor:

bash
Copiar código
sudo reboot
Comandos Detallados
Abre y edita /etc/hostname:

bash
Copiar código
sudo nano /etc/hostname
Cambia el contenido a:

plaintext
Copiar código
physical1.cefaslocalserver.com
Abre y edita /etc/hosts:

bash
Copiar código
sudo nano /etc/hosts
Encuentra y actualiza la línea:

plaintext
Copiar código
127.0.1.1   cefaslocalserver.com   cefaslocalserver
A:

plaintext
Copiar código
127.0.1.1   physical1.cefaslocalserver.com   physical1
Reinicia el servidor para aplicar los cambios:

bash
Copiar código
sudo reboot
Después de reiniciar, el nombre del servidor físico será physical1.cefaslocalserver.com, y puedes proceder con la configuración de FreeIPA sin conflictos de nombres.



Sí, puedes cambiar el nombre del servidor sin reiniciar usando los siguientes comandos:

Cambiar el nombre en /etc/hostname:

bash
Copiar código
sudo nano /etc/hostname
Cambia el contenido a:

plaintext
Copiar código
physical1.cefaslocalserver.com
Actualizar /etc/hosts:

bash
Copiar código
sudo nano /etc/hosts
Actualiza la línea correspondiente a:

plaintext
Copiar código
127.0.1.1   physical1.cefaslocalserver.com   physical1
Aplicar el nuevo nombre del host:

bash
Copiar código
sudo hostnamectl set-hostname physical1.cefaslocalserver.com
Recargar el nombre del host sin reiniciar:

bash
Copiar código
exec bash
Esto debería aplicar los cambios de nombre del servidor sin necesidad de reiniciar el sistema.