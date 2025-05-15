# Guía para Generar Certificados y Firmar grubx64.efi

Este documento describe el proceso completo para generar un certificado autofirmado, configurarlo en una base de datos NSS y usar **pesign** para firmar el archivo **grubx64.efi** en un sistema con **Secure Boot** habilitado.

## Pasos para Generar y Firmar Certificados

### 1. Crear un Directorio para Certificados

Primero, crea un directorio donde guardarás todos los archivos relacionados con los certificados y la firma.

```bash
mkdir -p ~/secureboot-certificates
cd ~/secureboot-certificates
```

### 2. Generar un Certificado Autofirmado

Genera una clave privada y un certificado autofirmado. Este certificado será válido por 365 días.

```bash
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -days 365 -nodes -subj "/CN=Mi Certificado MOK"
```

Este comando creará dos archivos:

- **MOK.key**: Clave privada.
- **MOK.crt**: Certificado público.

### 3. Convertir Certificado y Clave a Formato PKCS#12

Combina la clave privada y el certificado público en un archivo PKCS#12, que se utilizará para la firma.

```bash
openssl pkcs12 -export -inkey MOK.key -in MOK.crt -out MOK.p12 -name "Mi Certificado MOK"
```

Se te pedirá una contraseña para proteger el archivo PKCS#12. Utiliza una contraseña segura, por ejemplo: **qazwsxedc**.

### 4. Crear y Configurar la Base de Datos NSS

Crea un directorio para la base de datos NSS y establece los permisos adecuados.

```bash
sudo mkdir -p /root/pesign-nss-db
sudo chmod 700 /root/pesign-nss-db
```

### 5. Inicializar la Base de Datos NSS

Inicializa la base de datos NSS, la cual se usará para almacenar y gestionar los certificados.

```bash
sudo certutil -N -d sql:/root/pesign-nss-db
```

Durante este paso, se te pedirá que ingreses una contraseña para proteger la base de datos NSS. Utiliza una contraseña fácil de recordar, por ejemplo: **nssdb-password**.

### 6. Importar el Archivo PKCS#12 a la Base de Datos NSS

Importa el archivo PKCS#12 que contiene el certificado y la clave privada a la base de datos NSS.

```bash
sudo pk12util -i ~/secureboot-certificates/MOK.p12 -d sql:/root/pesign-nss-db
```

Se te solicitarán dos contraseñas:

- **Contraseña para la base de datos NSS**: Ingresa la contraseña que estableciste para la base de datos (**nssdb-password**).
- **Contraseña para el archivo PKCS#12**: Ingresa la contraseña que estableciste para el archivo PKCS#12 (**qazwsxedc**).

### 7. Verificar la Importación del Certificado

Verifica que el certificado se haya importado correctamente a la base de datos NSS.

```bash
sudo certutil -L -d sql:/root/pesign-nss-db
```

Deberías ver una salida similar a esta:

```plaintext
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           u,u,u
```

### 8. Configurar el Certificado como Confiable

Configura el certificado como confiable para firmar código, lo cual es necesario para la firma del archivo **grubx64.efi**.

```bash
sudo certutil -M -d sql:/root/pesign-nss-db -n "Mi Certificado MOK" -t "C,,C"
```

Verifica nuevamente para asegurarte de que los atributos de confianza estén configurados correctamente.

```bash
sudo certutil -L -d sql:/root/pesign-nss-db
```

La salida esperada debería ser:

```plaintext
Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

Mi Certificado MOK                                           Cu,u,Cu
```

### 9. Firmar el Archivo grubx64.efi

Ahora que el certificado está configurado, usa **pesign** para firmar el archivo **grubx64.efi** con el certificado.

```bash
sudo pesign --sign --certdir sql:/root/pesign-nss-db --cert "Mi Certificado MOK" --in /boot/efi/EFI/rocky/grubx64.efi --out ~/secureboot-certificates/grubx64-signed.efi
```

Se te pedirá la contraseña de la base de datos NSS. Ingresa la contraseña que configuraste previamente (**nssdb-password**).

### 10. Verificar la Firma

Verifica que el archivo haya sido firmado correctamente.

```bash
pesign --show-signature --in ~/secureboot-certificates/grubx64-signed.efi
```

Deberías ver detalles sobre la firma aplicada al archivo, lo que indica que el proceso de firma fue exitoso.

## Limpieza

Elimina los archivos temporales y directorios creados durante el proceso para mantener el sistema limpio.

```bash
sudo rm -rf /root/pesign-nss-db
rm -rf ~/secureboot-certificates
```

## Notas Importantes

- **Contraseñas utilizadas**:

  - **Base de datos NSS**: nssdb-password
  - **Archivo PKCS#12**: qazwsxedc

- **Errores comunes y soluciones**:

  - Error "The security password entered is incorrect": Asegúrate de usar la contraseña correcta (**nssdb-password**) cuando se te solicite.
  - Error "Could not find certificate": Verifica que el certificado esté importado correctamente usando **certutil -L**.

- **Organización y seguridad**:

  - Mantén el directorio **~/secureboot-certificates** organizado y realiza copias de seguridad de los certificados importantes para evitar pérdida de datos.
  - Recuerda las contraseñas establecidas en los pasos anteriores, ya que serán necesarias para futuras operaciones relacionadas con la base de datos NSS y la firma de archivos.
