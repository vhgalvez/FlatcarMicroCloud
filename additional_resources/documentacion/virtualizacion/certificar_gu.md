Entiendo que estás experimentando dificultades al firmar el archivo grubx64.efi utilizando pesign y un certificado autofirmado. A continuación, te proporcionaré una guía detallada para realizar este proceso correctamente.

sudo rm -rf /root/pesign-nss-db

1. Crear un directorio para los certificados:

bash
Copiar código
mkdir -p ~/secureboot-certificates
cd ~/secureboot-certificates
2. Generar un certificado autofirmado:

bash
Copiar código
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -days 365 -nodes -subj "/CN=Mi Certificado MOK"
Este comando crea una clave privada (MOK.key) y un certificado público (MOK.crt) válidos por 365 días.

3. Convertir el certificado y la clave a un archivo PKCS#12:

bash
Copiar código
openssl pkcs12 -export -inkey MOK.key -in MOK.crt -out MOK.p12 -name "Mi Certificado MOK"
Se te pedirá que establezcas una contraseña para el archivo PKCS#12.
contraseña qazwsxedc
4. Crear y configurar la base de datos NSS:

bash
Copiar código
sudo mkdir -p /root/pesign-nss-db
sudo chmod 700 /root/pesign-nss-db
5. Importar el archivo PKCS#12 a la base de datos NSS:

bash
Copiar código
sudo pk12util -i ~/secureboot-certificates/MOK.p12 -d sql:/root/pesign-nss-db
Durante la importación, se te solicitará:

Contraseña o PIN para "NSS Certificate DB": Ingresa una contraseña segura para proteger la base de datos NSS.
Contraseña para el archivo PKCS#12: Introduce la contraseña que estableciste al crear MOK.p12.
qazwsxedc

6. Verificar la importación del certificado:

bash
Copiar código
sudo certutil -L -d sql:/root/pesign-nss-db


Deberías ver una salida similar a:

markdown
Copiar código
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           u,u,u
7. Asignar atributos de confianza al certificado:

bash
Copiar código
sudo certutil -M -d sql:/root/pesign-nss-db -n "Mi Certificado MOK" -t "C,,C"
Esto establece el certificado como confiable para firmar código.

8. Firmar el archivo grubx64.efi con pesign:

bash
Copiar código
sudo pesign --sign --certdir sql:/root/pesign-nss-db --cert "Mi Certificado MOK" --in /boot/efi/EFI/rocky/grubx64.efi --out ~/secureboot-certificates/grubx64-signed.efi
Se te pedirá la contraseña de la base de datos NSS que estableciste anteriormente.

9. Verificar la firma del archivo:

bash
Copiar código
pesign --show-signature --in ~/secureboot-certificates/grubx64-signed.efi
Deberías ver detalles sobre la firma aplicada al archivo.

Nota: Asegúrate de recordar las contraseñas establecidas durante este proceso, ya que serán necesarias para futuras operaciones relacionadas con la base de datos NSS y los certificados.

Entiendo que estás experimentando problemas al firmar el archivo grubx64.efi utilizando pesign, específicamente con errores relacionados con la contraseña de la base de datos NSS. A continuación, te proporciono una guía detallada para realizar este proceso correctamente:

1. Crear un directorio para los certificados:

bash
Copiar código
mkdir -p ~/secureboot-certificates
cd ~/secureboot-certificates
2. Generar un certificado autofirmado:

bash
Copiar código
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -days 365 -nodes -subj "/CN=Mi Certificado MOK"
Este comando crea una clave privada (MOK.key) y un certificado público (MOK.crt) válidos por 365 días.

3. Convertir el certificado y la clave a un archivo PKCS#12:

bash
Copiar código
openssl pkcs12 -export -inkey MOK.key -in MOK.crt -out MOK.p12 -name "Mi Certificado MOK"
Se te pedirá que establezcas una contraseña para el archivo PKCS#12. Asegúrate de recordar esta contraseña, ya que la necesitarás en pasos posteriores.

4. Crear y configurar la base de datos NSS:

bash
Copiar código
sudo mkdir -p /root/pesign-nss-db
sudo chmod 700 /root/pesign-nss-db
5. Inicializar la base de datos NSS:

bash
Copiar código
sudo certutil -N -d sql:/root/pesign-nss-db
Durante este paso, se te solicitará que ingreses una contraseña para la base de datos NSS. Es importante que recuerdes esta contraseña, ya que será necesaria para operaciones futuras.

6. Importar el archivo PKCS#12 a la base de datos NSS:

bash
Copiar código
sudo pk12util -i ~/secureboot-certificates/MOK.p12 -d sql:/root/pesign-nss-db
Se te solicitarán dos contraseñas:

Contraseña o PIN para "NSS Certificate DB": Ingresa la contraseña que estableciste en el paso anterior al inicializar la base de datos NSS.
Contraseña para el archivo PKCS#12: Introduce la contraseña que estableciste al crear MOK.p12.
7. Verificar la importación del certificado:

bash
Copiar código
sudo certutil -L -d sql:/root/pesign-nss-db
Deberías ver una salida similar a:

markdown
Copiar código
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           u,u,u
8. Asignar atributos de confianza al certificado:

bash
Copiar código
sudo certutil -M -d sql:/root/pesign-nss-db -n "Mi Certificado MOK" -t "C,,C"
Esto establece el certificado como confiable para firmar código.

9. Firmar el archivo grubx64.efi con pesign:

bash
Copiar código
sudo pesign --sign --certdir sql:/root/pesign-nss-db --cert "Mi Certificado MOK" --in /boot/efi/EFI/rocky/grubx64.efi --out ~/secureboot-certificates/grubx64-signed.efi
Se te pedirá la contraseña de la base de datos NSS que estableciste anteriormente. Asegúrate de ingresarla correctamente.

10. Verificar la firma del archivo:

bash
Copiar código
pesign --show-signature --in ~/secureboot-certificates/grubx64-signed.efi
Deberías ver detalles sobre la firma aplicada al archivo.

Nota: Es fundamental que las contraseñas ingresadas durante este proceso sean consistentes y se recuerden para operaciones futuras. Si continúas experimentando problemas con la autenticación, verifica que las contraseñas ingresadas sean correctas y que no haya errores tipográficos.


Fuentes


Aquí tienes un paso a paso ordenado, en formato Markdown, para generar certificados y firmar el archivo grubx64.efi correctamente. Este proceso incluye contraseñas recomendadas y detalles claros para cada paso.

markdown
Copiar código
# Guía para Generar Certificados y Firmar grubx64.efi

Este documento describe cómo generar certificados, configurarlos en una base de datos NSS y firmar el archivo `grubx64.efi` utilizando `pesign`.

---

## 1. Crear un Directorio para Certificados

Crea un directorio organizado para almacenar los archivos relacionados con la firma:

```bash
mkdir -p ~/secureboot-certificates
cd ~/secureboot-certificates
2. Generar un Certificado Autofirmado
Genera una clave privada y un certificado autofirmado válido por 365 días:

bash
Copiar código
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -days 365 -nodes -subj "/CN=Mi Certificado MOK"
Esto crea dos archivos:

MOK.key: Clave privada.
MOK.crt: Certificado público.
3. Convertir Certificado y Clave a Formato PKCS#12
Crea un archivo PKCS#12 que combine la clave y el certificado:

bash
Copiar código
openssl pkcs12 -export -inkey MOK.key -in MOK.crt -out MOK.p12 -name "Mi Certificado MOK"
Se te pedirá una contraseña para proteger el archivo PKCS#12. Utiliza una contraseña sencilla pero segura, como:

Contraseña recomendada: qazwsxedc

4. Crear y Configurar la Base de Datos NSS
Crea el directorio y establece los permisos correctos para la base de datos NSS:

bash
Copiar código
sudo mkdir -p /root/pesign-nss-db
sudo chmod 700 /root/pesign-nss-db
5. Inicializar la Base de Datos NSS
Inicializa la base de datos NSS:

bash
Copiar código
sudo certutil -N -d sql:/root/pesign-nss-db
Se te pedirá una contraseña para la base de datos NSS. Utiliza una contraseña fácil de recordar, como:

Contraseña recomendada: nssdb-password

6. Importar el Archivo PKCS#12 a NSS
Importa el archivo PKCS#12 en la base de datos NSS:

bash
Copiar código
sudo pk12util -i ~/secureboot-certificates/MOK.p12 -d sql:/root/pesign-nss-db
Durante este paso, se te pedirá:

Contraseña o PIN para "NSS Certificate DB": Introduce nssdb-password.
Contraseña para el archivo PKCS#12: Introduce qazwsxedc.
7. Verificar la Importación del Certificado
Confirma que el certificado fue importado correctamente:

bash
Copiar código
sudo certutil -L -d sql:/root/pesign-nss-db
Deberías ver algo como:

plaintext
Copiar código
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           u,u,u
8. Configurar el Certificado como Confiable
Asigna atributos de confianza al certificado:

bash
Copiar código
sudo certutil -M -d sql:/root/pesign-nss-db -n "Mi Certificado MOK" -t "C,,C"
Verifica nuevamente:

bash
Copiar código
sudo certutil -L -d sql:/root/pesign-nss-db
Salida esperada:

plaintext
Copiar código
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           Cu,u,Cu
9. Firmar el Archivo grubx64.efi
Firma el archivo con el certificado:

bash
Copiar código
sudo pesign --sign --certdir sql:/root/pesign-nss-db --cert "Mi Certificado MOK" --in /boot/efi/EFI/rocky/grubx64.efi --out ~/secureboot-certificates/grubx64-signed.efi
Si se te pide una contraseña, introduce nssdb-password.

10. Verificar la Firma
Verifica que el archivo fue firmado correctamente:

bash
Copiar código
pesign --show-signature --in ~/secureboot-certificates/grubx64-signed.efi
Deberías ver detalles sobre la firma aplicada.

Notas Importantes
Contraseñas utilizadas:

Base de datos NSS: nssdb-password
Archivo PKCS#12: qazwsxedc
Errores comunes y soluciones:

Error "The security password entered is incorrect": Asegúrate de usar la contraseña correcta (nssdb-password) al acceder a la base de datos NSS.
Error "Could not find certificate": Verifica que el certificado esté importado correctamente con certutil -L.
Mantén el directorio ~/secureboot-certificates organizado y realiza una copia de seguridad de los certificados importantes.