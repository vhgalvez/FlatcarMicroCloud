# Guía de Instalación y Configuración del Servidor DNS con FreeIPA en Rocky Linux

## Introducción

Este documento proporciona una guía detallada para la instalación y configuración de FreeIPA como servidor DNS en Rocky Linux. FreeIPA es una solución integrada de identidad y autenticación que incluye características como Kerberos, LDAP, DNS y NTP.

## Paso 1: Preparación del Sistema

### 1.1 Actualizar el Sistema

```bash
sudo dnf update -y && sudo dnf updagrade -y

```

### 1.2 Verificar el Nombre de Host

```bash
cat /etc/hostname
```


### 1.3 Verificar el Archivo /etc/hosts

```bash
cat /etc/hosts
```

## Paso 2: Instalación de FreeIPA

### 2.1 Instalar FreeIPA y el Servidor DNS

```bash

sudo dnf install -y ipa-server ipa-server-dns
```

### 2.2 Ejecutar el Script de Instalación de FreeIPA

```bash
sudo ipa-server-install
```

Durante la instalación, sigue las instrucciones en pantalla y proporciona los parámetros necesarios como el dominio, el realm y la contraseña de administración.




```bash
[core@freeipa1 ~]$ sudo ipa-server-install

The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.
Version 4.11.0

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the NTP client (chronyd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure SID generation
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.

Do you want to configure integrated DNS (BIND)? [no]: yes

Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com


Server host name [freeipa1.cefaslocalserver.com]: freeipa1.cefaslocalserver.com

Warning: skipping DNS resolution of host freeipa1.cefaslocalserver.com
The domain name has been determined based on the host name.

Please confirm the domain name [cefaslocalserver.com]: cefaslocalserver.com

The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [CEFASLOCALSERVER.COM]: CEFASLOCALSERVER.COM
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long.

Directory Manager password:
Password (confirm):

The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password:
Password (confirm):

Checking DNS domain cefaslocalserver.com., please wait ...
Do you want to configure DNS forwarders? [yes]: no
No DNS forwarders configured
Do you want to search for missing reverse zones? [yes]: yes
Checking DNS domain 3.17.10.in-addr.arpa., please wait ...
Reverse zone 3.17.10.in-addr.arpa. for IP address 10.17.3.11 already exists
Trust is configured but no NetBIOS domain name found, setting it now.
Enter the NetBIOS name for the IPA domain.
Only up to 15 uppercase ASCII letters, digits and dashes are allowed.
Example: EXAMPLE.


NetBIOS domain name [CEFASLOCALSERVE]: CEFASLOCALSERVE

Do you want to configure chrony with NTP server or pool address? [no]: no

The IPA Master Server will be configured with:
Hostname:       freeipa1.cefaslocalserver.com
IP address(es): 10.17.3.11
Domain name:    cefaslocalserver.com
Realm name:     CEFASLOCALSERVER.COM

The CA will be configured with:
Subject DN:   CN=Certificate Authority,O=CEFASLOCALSERVER.COM
Subject base: O=CEFASLOCALSERVER.COM
Chaining:     self-signed

BIND DNS server will be configured to serve IPA domain with:
Forwarders:       No forwarders
Forward policy:   only
Reverse zone(s):  No reverse zone

Continue to configure the system with these values? [no]: yes

The following operations may take some minutes to complete.
```

### 2.3 Verificar la Instalación de FreeIPA

```bash
sudo systemctl status named
```

```bash
[core@freeipa1 ~]$ sudo systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: disabled)
     Active: active (running) since Fri 2024-07-05 18:01:44 BST; 18min ago
   Main PID: 31992 (named)
      Tasks: 11 (limit: 24608)
     Memory: 29.7M
        CPU: 339ms
     CGroup: /system.slice/named.service
             └─31992 /usr/sbin/named -u named -c /etc/named.conf -E pkcs11

Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 0.in-addr.arpa/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 1.0.0.127.in-addr.arpa/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone localhost/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip>
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone localhost.localdomain/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: all zones loaded
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: running
Jul 05 18:01:44 freeipa1.cefaslocalserver.com systemd[1]: Started Berkeley Internet Name Domain (DNS).
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone cefaslocalserver.com/IN: loaded serial 1720198904
Jul 05 18:15:24 freeipa1.cefaslocalserver.com named[31992]: zone cefaslocalserver.com/IN: zone_journal_compact: could not get zone >
```

```bash
sudo systemctl enable named
```

## Paso 3: Configuración del Servidor DNS en FreeIPA

### 3.1 Configurar el DNS durante la Instalación de FreeIPA

Selecciona la opción de configurar el servidor DNS durante la instalación y proporciona la información requerida.


3.2 Verificación de la Configuración del DNS

```bash
dig freeipa1.cefaslocalserver.com
```
## Paso 4 Configuración de Reenvío de DNS en FreeIPA

### Configurar los reenviadores DNS en FreeIPA:

```bash
[core@freeipa1 ~]$ kinit admin
Password for admin@CEFASLOCALSERVER.COM:
```
12345678

Asegúrate de que FreeIPA esté configurado para reenviar solicitudes DNS que no pueda resolver internamente a un servidor DNS externo, como el de Google (8.8.8.8). Si no lo configuraste durante la instalación, puedes hacerlo manualmente.

```bash
ipa dnsconfig-mod --forwarder=8.8.8.8
```


# Resolución de Problemas de DNS Externa en FreeIPA

## Introducción

Esta guía detalla cómo solucionar problemas de resolución de DNS externa en FreeIPA, deshabilitando la validación DNSSEC.

## Paso 1: Verificar y Configurar DNSSEC

### Editar el Archivo de Configuración de named

```bash
sudo vi /etc/named/ipa-options-ext.conf
```

## Deshabilitar DNSSEC

Asegúrate de que la opción dnssec-validation esté configurada en no:


```bash
/* User customization for BIND named
 *
 * This file is included in /etc/named.conf and is not modified during IPA
 * upgrades.
 *
 * It must only contain "options" settings. Any other setting must be
 * configured in /etc/named/ipa-ext.conf.
 *
 * Examples:
 * allow-recursion { trusted_network; };
 * allow-query-cache { trusted_network; };
 */

/* turns on IPv6 for port 53, IPv4 is on by default for all ifaces */
listen-on-v6 { any; };

/* dnssec-enable is obsolete and 'yes' by default */
dnssec-validation no;

/* Permitir recursión para todas las redes */
allow-recursion { any; };

/* Forwarders */
forwarders {
    8.8.8.8;
    8.8.4.4;
};

```

## Reiniciar el Servicio named

Guarda los cambios y reinicia el servicio DNS:

```bash
sudo systemctl restart named
```
Verificar el Estado del Servicio

```bash
sudo systemctl status named
journalctl -xeu named.service
```
## Paso 2: Verificar la Resolución de DNS

### Verificar la Resolución de DNS

```bash
dig google.com
```

## Paso 3: Limpiar la Caché de DNS (Opcional)

### Limpiar la Caché de DNS
        
```bash
sudo rndc flush
```

### Paso 4: Verificar la Configuración de Firewall

Listar las Reglas del Firewall

```bash
sudo firewall-cmd --list-all
```
### Permitir el Tráfico DNS si es Necesario


```bash
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --permanent --add-port=53/tcp
sudo firewall-cmd --reload
```
### Paso 5: Verificar la Conectividad de Red

### Verificar la Conectividad Hacia el Reenviador DNS

```bash
ping 8.8.8.8
```

## Resumen

1. Editar `/etc/named/ipa-options-ext.conf`:
 
Añade `dnssec-validation no;` al bloque de opciones.

2. Reiniciar el servicio `named`:
        

```bash
sudo systemctl restart named
```

3. Verificar los Reenviadores DNS:

```bash
ipa dnsconfig-mod --forwarder=8.8.8.8
```

4. Probar la Resolución DNS:

```bash
dig google.com
```

5. Verificar la Configuración de Firewall:

```bash
sudo firewall-cmd --list-all
```

1. Verificar la Conectividad de Red:

```bash
ping 8.8.8.8
```

## Ejemplo de Archivo de Configuración de `named`

 El archivo /etc/named.conf no hay modificarlo, ya que es gestionado por FreeIPA. Sin embargo, puedes ver la configuración actual del servicio DNS en FreeIPA.

```bash
sudo cat /etc/named.conf
```

```bash
/* WARNING: This config file is managed by IPA.
 *
 * DO NOT MODIFY! Any modification will be overwritten by upgrades.
 *
 *
 * - /etc/named/ipa-options-ext.conf (for options)
 * - /etc/named/ipa-logging-ext.conf (for logging options)
 * - /etc/named/ipa-ext.conf (all other settings)
 */

options {
        // Put files that named is allowed to write in the data/ directory:
        directory "/var/named"; // the default
        dump-file               "data/cache_dump.db";
        statistics-file         "data/named_stats.txt";
        memstatistics-file      "data/named_mem_stats.txt";

        tkey-gssapi-keytab "/etc/named.keytab";

        pid-file "/run/named/named.pid";

        managed-keys-directory "/var/named/dynamic";

        /* user customizations of options */
        include "/etc/named/ipa-options-ext.conf";

        /* crypto policy snippet on platforms with system-wide policy. */
        include "/etc/crypto-policies/back-ends/bind.config";
};

/* If you want to enable debugging, eg. using the 'rndc trace' command,
 * By default, SELinux policy does not allow named to modify the /var/named directory,
 * so put the default debug log file in data/ :
 */
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
                print-time yes;
        };
        include "/etc/named/ipa-logging-ext.conf";
};

zone "." IN {
        type hint;
        file "named.ca";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";

/* user customization */
include "/etc/named/ipa-ext.conf";

dyndb "ipa" "/usr/lib64/bind/ldap.so" {
        uri "ldapi://%2fvar%2frun%2fslapd-CEFASLOCALSERVER-COM.socket";
        base "cn=dns,dc=cefaslocalserver,dc=com";
        server_id "freeipa1.cefaslocalserver.com";
        auth_method "sasl";
        sasl_mech "EXTERNAL";
        krb5_keytab "FILE:/etc/named.keytab";
};
```

# Solución de Problemas de DNS con FreeIPA y Kerberos

Para solucionar el problema de las credenciales de Kerberos al intentar añadir registros DNS en FreeIPA, sigue estos pasos:

## Paso 1: Obtener un Ticket de Kerberos

Primero, necesitas obtener un ticket de Kerberos con el usuario admin. Ejecuta `kinit` para obtener un ticket:

```bash
kinit admin
```

Introduce la contraseña del usuario admin cuando se te pida. Este comando debe completarse sin errores.

## Paso 2: Añadir Registros DNS

```bash
ipa dnsrecord-add cefaslocalserver.com bootstrap --a-rec 10.17.4.27
ipa dnsrecord-add cefaslocalserver.com helper --a-rec 10.17.3.14
ipa dnsrecord-add cefaslocalserver.com master1 --a-rec 10.17.4.21
ipa dnsrecord-add cefaslocalserver.com master2 --a-rec 10.17.4.22
ipa dnsrecord-add cefaslocalserver.com master3 --a-rec 10.17.4.23
ipa dnsrecord-add cefaslocalserver.com worker1 --a-rec 10.17.4.24
ipa dnsrecord-add cefaslocalserver.com worker2 --a-rec 10.17.4.25
ipa dnsrecord-add cefaslocalserver.com worker3 --a-rec 10.17.4.26
ipa dnsrecord-add cefaslocalserver.com bastion1 --a-rec 192.168.0.20
ipa dnsrecord-add cefaslocalserver.com freeipa1 --a-rec 10.17.3.11
ipa dnsrecord-add cefaslocalserver.com load_balancer1 --a-rec 10.17.3.12
ipa dnsrecord-add cefaslocalserver.com postgresql1 --a-rec 10.17.3.1
```

Verificación de Credenciales de Kerberos

Si sigues recibiendo el error "did not receive Kerberos credentials", puede que necesites asegurarte de que tu ticket de Kerberos esté vigente y que el tiempo de vida del ticket no haya expirado. Verificar el ticket de Kerberos:

```bash
klist
```

## Paso 3: Verificar los Registros DNS


```bash
kinit admin
```

```bash

ipa dnsrecord-find cefaslocalserver.com
```

Verificar la resolución DNS desde una VM

```bash
dig physical1.cefaslocalserver.com
dig freeipa1.cefaslocalserver.com
dig bootstrap1.cefaslocalserver.com
dig master1.cefaslocalserver.com
dig google.com
```
```bash
ping -c 4 physical1.cefaslocalserver.com
ping -c 4 bootstrap1.cefaslocalserver.com
ping -c 4 master1.cefaslocalserver.com
ping -c 4 google.com
```


sudo systemctl ena named


Verificar el estado del servicio DNS

```bash
sudo systemctl status named
```
Verificar la configuración del firewall en el servidor FreeIPA
Asegúrate de que el firewall permite el tráfico DNS en los puertos 53 TCP/UDP.



```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --permanent --add-port=53/tcp
sudo firewall-cmd --reload

```

Limpiar la caché DNS en las VMs

```bash
sudo systemd-resolve --flush-caches
sudo systemctl restart systemd-resolved
```

Verificar la conectividad hacia el servidor FreeIPA

```bash
ping -c 4 10.17.3.11
```

verificar el servicio named

```bash
[core@freeipa1 ~]$ sudo systemctl status named
● named.service - Berkeley Internet Name Domain (DNS)
     Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; preset: disabled)
     Active: active (running) since Fri 2024-07-05 18:01:44 BST; 18min ago
   Main PID: 31992 (named)
      Tasks: 11 (limit: 24608)
     Memory: 29.7M
        CPU: 339ms
     CGroup: /system.slice/named.service
             └─31992 /usr/sbin/named -u named -c /etc/named.conf -E pkcs11

Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 0.in-addr.arpa/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 1.0.0.127.in-addr.arpa/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone localhost/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip>
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone localhost.localdomain/IN: loaded serial 0
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: all zones loaded
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: running
Jul 05 18:01:44 freeipa1.cefaslocalserver.com systemd[1]: Started Berkeley Internet Name Domain (DNS).
Jul 05 18:01:44 freeipa1.cefaslocalserver.com named[31992]: zone cefaslocalserver.com/IN: loaded serial 1720198904
Jul 05 18:15:24 freeipa1.cefaslocalserver.com named[31992]: zone cefaslocalserver.com/IN: zone_journal_compact: could not get zone >
lines 1-20/20 (END)
```



## Solución de Problemas de Resolución de DNS Externa en FreeIPA

Abre el archivo `/etc/named.conf` o el archivo donde se incluyan las opciones de configuración 

(`/etc/named/ipa-options-ext.conf` en el caso de FreeIPA).

Agrega o modifica la opción allow-recursion para incluir las redes que deben permitir la recursión:

```bash
sudo vim /etc/named/ipa-options-ext.conf
```

Agrega la siguiente línea para permitir la recursión para todas las redes:
```bash
    allow-recursion { any; }; # Permitir recursión para todas las redes
```

Guarda los cambios y reinicia el servicio named:

```bash
sudo systemctl restart named
```
Verifica el estado del servicio para asegurarte de que no hay errores:

```bash
sudo systemctl status named
```
Prueba la resolución de DNS nuevamente para dominios externos:


```bash
dig google.com
```
Si sigues estos pasos, deberías poder resolver dominios externos correctamente.

```bash
/* User customization for BIND named
 *
 * This file is included in /etc/named.conf and is not modified during IPA
 * upgrades.
 *
 * It must only contain "options" settings. Any other setting must be
 * configured in /etc/named/ipa-ext.conf.
 *
 * Examples:
 * allow-recursion { trusted_network; };
 * allow-query-cache { trusted_network; };
 */

/* turns on IPv6 for port 53, IPv4 is on by default for all ifaces */
listen-on-v6 { any; };

/* dnssec-enable is obsolete and 'yes' by default */
dnssec-validation no;

/* Permitir recursión para todas las redes */
allow-recursion { any; };
```

```bash
sudo systemctl restart named
```



```bash
dig google.com
```

## Recursos de Terraform para Redes

# Redes Virtuales y Configuración

Este documento proporciona una guía detallada de las configuraciones de red para diferentes entornos virtuales y el servidor físico. Incluye la configuración de redes NAT y Bridge, así como la asignación de IPs y roles de nodos específicos. La infraestructura está creada con Terraform y KVM, utilizando redes NAT e IPs asignadas.

## Entrada para el Servidor Físico

El servidor físico actúa como el anfitrión principal para las máquinas virtuales y otros servicios críticos. Es fundamental asegurar que este servidor esté configurado adecuadamente y mantenido en buen estado.

| Dirección IP  | Hostname                        | Alias     |
|---------------|---------------------------------|-----------|
| 192.168.0. ?  | physical1.cefaslocalserver.com  | physical1 |

## Redes Virtuales y su Configuración

### Red br0 - Bridge Network

La red `br0` se utiliza para proporcionar acceso seguro y un punto de conexión de bridge. Esta red permite la comunicación directa con el servidor físico y otras redes externas, asegurando un acceso controlado.

| Red NAT | Nodos    | Dirección IP | Rol del Nodo                            | Interfaz de Red |
|---------|----------|--------------|-----------------------------------------|-----------------|
| br0     | bastion1 | 192.168.0.20 | Acceso seguro, Punto de conexión de bridge | enp3s0f1        |

### Red kube_network_02 - NAT Network

La red `kube_network_02` se utiliza para los servicios básicos del clúster, incluyendo DNS, balanceo de carga, y gestión de bases de datos. Esta red asegura que los servicios críticos del clúster estén en un entorno seguro y bien gestionado.

| Red NAT        | Nodos          | Dirección IP | Rol del Nodo                     | Interfaz de Red |
|----------------|----------------|--------------|----------------------------------|-----------------|
| kube_network_02 | freeipa1       | 10.17.3.11   | Servidor de DNS y gestión de identidades | (Virtual - NAT) |
| kube_network_02 | load_balancer1 | 10.17.3.12   | Balanceo de carga para el clúster | (Virtual - NAT) |
| kube_network_02 | postgresql1    | 10.17.3.13   | Gestión de bases de datos         | (Virtual - NAT) |
| kube_network_02 | bootstrap1     | 10.17.3.14   | Inicialización del clúster        | (Virtual - NAT) |

### Red kube_network_03 - NAT Network

La red `kube_network_03` se dedica a la gestión y ejecución de aplicaciones dentro del clúster. Esta separación asegura que las aplicaciones se ejecuten de manera eficiente y segura, sin interferir con otros servicios críticos.

| Red NAT        | Nodos          | Dirección IP | Rol del Nodo              | Interfaz de Red |
|----------------|----------------|--------------|---------------------------|-----------------|
| kube_network_03 | master1        | 10.17.4.21   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | master2        | 10.17.4.22   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | master3        | 10.17.4.23   | Gestión del clúster        | (Virtual - NAT) |
| kube_network_03 | worker1        | 10.17.4.24   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | worker2        | 10.17.4.25   | Ejecución de aplicaciones  | (Virtual - NAT) |
| kube_network_03 | worker3        | 10.17.4.26   | Ejecución de aplicaciones  | (Virtual - NAT) |

## Resumen de los Hostnames e IPs

A continuación se proporciona un resumen de los hostnames e IPs para referencia rápida. Esta tabla es crucial para la gestión y monitorización del entorno, permitiendo una identificación rápida de cada nodo y su rol.

| Dirección IP  | Hostname                         |
|---------------|----------------------------------|
| 10.17.3.11    | freeipa1.cefaslocalserver.com    |
| 10.17.3.12    | load_balancer1.cefaslocalserver.com |
| 10.17.3.13    | postgresql1.cefaslocalserver.com |
| 10.17.3.14    | bootstrap1.cefaslocalserver.com  |
| 10.17.4.21    | master1.cefaslocalserver.com     |
| 10.17.4.22    | master2.cefaslocalserver.com     |
| 10.17.4.23    | master3.cefaslocalserver.com     |
| 10.17.4.24    | worker1.cefaslocalserver.com     |
| 10.17.4.25    | worker2.cefaslocalserver.com     |
| 10.17.4.26    | worker3.cefaslocalserver.com     |


### Red br0 - Bridge Network

```hcl
resource "libvirt_network" "br0" {
  name      = var.rocky9_network_name
  mode      = "bridge"
  bridge    = "br0"
  autostart = true
  addresses = ["192.168.0.0/24"]
```

### Red kube_network_02 - NAT Network

```hcl
resource "libvirt_network" "kube_network_02" {
  name      = "kube_network_02"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.3.0/24"]
}
```

### Red kube_network_03 - NAT Network

```hcl
resource "libvirt_network" "kube_network_03" {
  name      = "kube_network_03"
  mode      = "nat"
  autostart = true
  addresses = ["10.17.4.0/24"]
}
```


Directory Manager password:
Password (confirm):
12345678

kinit admin
12345678

