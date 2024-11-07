Guía para Configurar un Servidor Nginx con Docker Compose
Este tutorial te guiará a través de los pasos necesarios para instalar y configurar un servidor web Nginx utilizando Docker Compose en un sistema basado en Linux. Incluye la creación de un contenedor Docker para Nginx y su configuración a través de Docker Compose.

Paso 1: Preparar el Entorno de Trabajo
Primero, crea un directorio de trabajo donde se almacenarán todos los archivos necesarios para la configuración del servidor Nginx.

bash
Copiar código
mkdir ~/nginx-docker
cd ~/nginx-docker
Paso 2: Crear el Archivo docker-compose.yml
Crea un archivo docker-compose.yml en el directorio de trabajo. Este archivo define los servicios que se ejecutarán en contenedores Docker, en este caso, Nginx.

bash
Copiar código
nano docker-compose.yml
Dentro del archivo docker-compose.yml, añade el siguiente contenido:

yaml
Copiar código
version: '3'
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
      - ./certificates:/etc/nginx/certificates-exposed:ro
      - ./nginx-certs:/etc/nginx/certificates:ro
    restart: always
Explicación de la Configuración:
nginx.conf: Archivo de configuración principal de Nginx.
html: Directorio donde se almacenarán los archivos HTML que se servirán.
certificates: Directorio para los certificados expuestos, montado en /etc/nginx/certificates-exposed.
nginx-certs: Directorio para los certificados SSL, montado en /etc/nginx/certificates.
Paso 3: Configurar Nginx
A continuación, crea un archivo de configuración para Nginx llamado nginx.conf en el mismo directorio.

bash
Copiar código
nano nginx.conf
Añade la siguiente configuración básica para servir contenido estático y manejar conexiones HTTPS:

nginx
Copiar código

events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ =404;
        }

        # Exponer el directorio de certificados para su descarga, solo accesible desde las redes internas
        location /certificates/ {
            alias /etc/nginx/certificates-exposed/;
            autoindex on;  # Habilita el listado de archivos en el directorio
            allow 10.17.3.0/24;
            allow 10.17.4.0/24;
            deny all;
        }

        # Exponer el directorio de instalación de CRI-O, solo accesible desde las redes internas
        location /install-cri-o/ {
            alias /home/core/nginx-docker/install-cri-o/;
            autoindex on;  # Habilita el listado de archivos en el directorio
            allow 10.17.3.0/24;
            allow 10.17.4.0/24;
            deny all;
        }

        listen 443 ssl;
        ssl_certificate /etc/nginx/certificates/server.crt;
        ssl_certificate_key /etc/nginx/certificates/server.key;
    }
}



Paso 4: Crear el Directorio de Contenido HTML
Crea un directorio html para almacenar el archivo index.html que se servirá por Nginx.

bash
Copiar código
mkdir html
echo '<h1>Welcome to Nginx!</h1>' > html/index.html
Paso 5: Iniciar el Servidor Nginx
Ahora puedes iniciar el servidor Nginx utilizando Docker Compose. Asegúrate de estar en el directorio donde se encuentra el archivo docker-compose.yml.

bash
Copiar código
docker-compose up -d
El parámetro -d asegura que el contenedor se ejecute en segundo plano.

Paso 6: Verificar los Logs y Detener el Servidor
Puedes verificar los logs para asegurarte de que todo esté funcionando correctamente:

bash
Copiar código
docker-compose logs -f
Si deseas detener el servidor en algún momento, utiliza el siguiente comando:

bash
Copiar código
docker-compose down
Paso 7: Generar el Certificado SSL para Nginx
Si aún no tienes un certificado SSL, puedes generar un certificado auto-firmado para Nginx.

Crear un nuevo directorio para los certificados de Nginx:
bash
Copiar código
mkdir /home/core/nginx-docker/nginx-certs
``
Generar el certificado SSL para Nginx:
bash
Copiar código
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /home/core/nginx-docker/nginx-certs/server.key -out /home/core/nginx-docker/nginx-certs/server.crt -subj "/CN=localhost"
Este comando genera un certificado y una clave que son necesarios para que Nginx pueda manejar conexiones HTTPS.

Resumen y Explicación
Este tutorial te ha guiado a través de la creación y configuración de un servidor Nginx utilizando Docker Compose. Has aprendido a configurar los archivos necesarios (docker-compose.yml y nginx.conf), a generar un certificado SSL auto-firmado, y a exponer un directorio para permitir la descarga de certificados a través de Nginx.

Posibles Mejoras:
Seguridad: Considera implementar medidas de seguridad adicionales, como la autenticación básica para proteger el acceso a los certificados expuestos.
Automatización: Puedes crear scripts adicionales para automatizar la generación y renovación de certificados.
Nombres Sugeridos para el Documento:
"Guía para Configurar un Servidor Nginx con Docker Compose"
"Configuración de Nginx en Docker Compose: Paso a Paso"
Paso 8: Instalar Git y Clonar un Repositorio
Si necesitas clonar un repositorio para obtener más recursos o configuraciones, puedes instalar Git y clonar el repositorio requerido.

Instalar Git:
bash
Copiar código
sudo dnf install git
Clonar el Repositorio:
bash
Copiar código
git clone https://github.com/vhgalvez/generate_certificates_cluster.git
Este paso te permite obtener scripts adicionales, como los necesarios para generar certificados de clúster en Kubernetes, o cualquier otro recurso que puedas necesitar.

Resumen y Explicación
Este tutorial te guía a través de la creación y configuración de un servidor Nginx utilizando Docker Compose. Los archivos de configuración (docker-compose.yml y nginx.conf) están diseñados para exponer un servidor web en los puertos 80 y 443, con soporte para HTTPS mediante certificados SSL. Además, se muestran comandos útiles para manejar el ciclo de vida del contenedor Docker y la instalación de Git para clonar repositorios adicionales.

Puedes nombrar este documento como "Guía para Configurar un Servidor Nginx con Docker Compose" o "Configuración de Nginx en Docker Compose: Paso a Paso" según prefieras.
