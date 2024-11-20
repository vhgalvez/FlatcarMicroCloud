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