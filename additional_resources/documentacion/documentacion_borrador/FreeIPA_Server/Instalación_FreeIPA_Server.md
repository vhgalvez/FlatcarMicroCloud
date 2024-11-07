# Instalación y Configuración de FreeIPA Server como Servidor DNS

Este documento proporciona una guía paso a paso para la instalación y configuración de FreeIPA como servidor DNS en un nodo específico. Asegúrate de seguir cada paso con precisión para garantizar una configuración exitosa.

Prerrequisitos

Sistema Operativo: Rocky Linux.

Acceso Root: Asegúrate de tener privilegios de superusuario (root).

Actualización del Sistema: Antes de comenzar, asegúrate de que el sistema esté actualizado.

```bash
sudo dnf update -y
```

## Paso 1: Instalación de FreeIPA Server

### Paso 1.1: Configuración del Repositorio

Primero, instala el repositorio EPEL y el repositorio de FreeIPA:



```bash
sudo dnf install epel-release -y
sudo dnf install ipa-server ipa-server-dns -y
```
### Paso 1.2: Instalación de FreeIPA Server

Instala el paquete FreeIPA Server:

```bash
sudo dnf install freeipa-server -y
```

## Paso 2: Configuración de FreeIPA Server

### Paso 2.1: Preparar la Instalación de FreeIPA

Ejecuta el instalador de FreeIPA:

```bash
sudo ipa-server-install
```

Sigue las instrucciones en pantalla y proporciona la información requerida:

Configuración DNS: Acepta la configuración para que FreeIPA configure y administre el DNS.
Dominio: Proporciona el nombre de dominio.
Contraseña de Admin: Configura una contraseña de administrador.
Ejemplo de Respuesta a las Preguntas del Instalador
less

```plaintext
Do you want to configure integrated DNS (BIND)? [no]: yes
Server host name [ipa.example.com]: ipa.cefaslocalserver.com
Please confirm the domain name [example.com]: cefaslocalserver.com
Please provide a realm name [EXAMPLE.COM]: CEFASLOCALSERVE.COM
Directory Manager password: ********
IPA admin password: ********
```

Paso 2.2: Configuración del Firewall

Permite los servicios necesarios en el firewall:

css

```bash
sudo firewall-cmd --add-service=freeipa-ldap --permanent
sudo firewall-cmd --add-service=freeipa-ldaps --permanent
sudo firewall-cmd --add-service=freeipa-replication --permanent
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
```

Paso 2.3: Iniciar y Habilitar FreeIPA

Asegúrate de que FreeIPA esté habilitado y en ejecución:



```bash
sudo systemctl enable ipa
sudo systemctl start ipa
```

Paso 3: Configuración de DNS en FreeIPA

Paso 3.1: Agregar un Registro DNS

Usa las herramientas de línea de comandos de FreeIPA para agregar un registro DNS:



```bash
ipa dnsrecord-add cefaslocalserver.com test --a-rec 192.0.2.1
```

Paso 3.2: Verificar los Registros DNS

Verifica la configuración de los registros DNS:



```bash
ipa dnsrecord-find cefaslocalserver.com
```

Paso 4: Administración de FreeIPA

Paso 4.1: Acceso a la Interfaz Web

Accede a la interfaz web de FreeIPA a través de la dirección URL: https://ipa.cefaslocalserver.com

Paso 4.2: Gestión de Usuarios y Políticas
A través de la interfaz web, puedes gestionar usuarios, grupos, políticas de acceso y registros DNS.

Paso 5: Configuración Adicional

Paso 5.1: Configuración de NTP

Asegúrate de que el servidor FreeIPA esté sincronizado con un servidor NTP:


```bash
sudo dnf install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd
```

Configura los servidores NTP en el archivo /etc/chrony.conf:


```plaintext
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
```
Paso 5.2: Configuración de Certificados SSL
Si deseas configurar SSL con certificados propios, sigue la documentación de FreeIPA para agregar certificados personalizados.

Conclusión
Siguiendo estos pasos, habrás instalado y configurado FreeIPA como servidor DNS en tu entorno. FreeIPA proporcionará gestión centralizada de identidades, políticas de seguridad y resolución de nombres DNS para tu infraestructura. Si encuentras algún problema, revisa los registros en /var/log/ipaserver-install.log y la documentación oficial de FreeIPA para obtener asistencia adicional.