Instalación y Configuración de Nginx en Docker con Docker Compose
Paso 1: Crear el archivo index.html en el servidor anfitrión
Primero, necesitas crear el archivo index.html que se usará para demostrar Nginx cuando lo ejecute en un contenedor Docker. Puedes crear este archivo en cualquier lugar del servidor donde tengas acceso de escritura. En este ejemplo, lo crearemos en el directorio /var/www/html.

Crea el directorio y navega a él:

bash
Copiar código
mkdir -p /var/www/html && cd /var/www/html
Crea el archivo index.html:

bash
Copiar código
vim index.html
Inserta el siguiente código en el archivo index.html:

html
Copiar código
<!DOCTYPE html>
<html>
<head>
    <title>¡Hola, Nginx!</title>
</head>
<body>
    <h1>¡Hola, Nginx!</h1>
    <p>Esta es una página de prueba servida por Nginx en un contenedor Docker.</p>
</body>
</html>
Guarda el archivo y sal de vim (presiona Esc, luego :wq y Enter).

Paso 2: Crear el archivo docker-compose.yaml
A continuación, debes crear el archivo docker-compose.yaml que define el contenedor Nginx y su configuración. Este archivo puede ser creado en cualquier lugar del servidor donde tengas acceso de escritura. En este ejemplo, lo crearemos en el directorio /opt/nginx.

Crea el directorio y el archivo:

bash
Copiar código
mkdir -p /opt/nginx && cd /opt/nginx
vim docker-compose.yaml
Agrega el siguiente contenido al archivo docker-compose.yaml:

yaml
Copiar código
version: '3'

services:
  nginx:
    image: nginx:latest
    ports:
      - "9999:80"
    volumes:
      - /var/www/html:/usr/share/nginx/html
    restart: always
services: Define la lista de servicios que queremos ejecutar usando Docker Compose.
nginx: Es el nombre del servicio que queremos ejecutar.
image: Especifica la imagen Docker que queremos usar. En este caso, estamos usando la imagen oficial de Nginx etiquetada como latest.
ports: Define el mapeo de puertos entre el host y el contenedor. En este caso, mapeamos el puerto 9999 en el host al puerto 80 en el contenedor.
volumes: Define el volumen que queremos usar para almacenar datos dentro del contenedor. En este caso, montamos el directorio /var/www/html en el host al directorio /usr/share/nginx/html en el contenedor.
restart: Especifica si Docker debe reiniciar automáticamente el contenedor si se detiene. En este caso, indicamos que el contenedor debe reiniciarse siempre.
Guarda el archivo y sal de vim (presiona Esc, luego :wq y Enter).

Paso 3: Ejecutar Docker Compose
Ahora estamos listos para ejecutar el contenedor Nginx usando Docker Compose. Ejecuta el siguiente comando desde el directorio donde se encuentra el archivo docker-compose.yaml:

bash
Copiar código
docker-compose up -d
Este comando iniciará el contenedor Nginx en segundo plano y mostrará su ID.

Para verificar si el contenedor está funcionando, usa el comando:

bash
Copiar código
docker-compose ps
Paso 4: Verificar Nginx
Ahora puedes verificar el funcionamiento de Nginx abriendo un navegador web y navegando a http://<dirección del servidor anfitrión>:9999. En nuestro ejemplo, será http://IP:9999.

Si todo está configurado correctamente, deberías ver la página "¡Hola, Nginx!".

Conclusión
¡Eso es todo! Ahora puedes usar Docker Compose para administrar contenedores Nginx y otras aplicaciones en tu servidor anfitrión.