
# Configuración de NTP en FreeIPA (Servidor) y Clientes

Este documento detalla los pasos para configurar el servidor NTP en FreeIPA y los clientes del clúster utilizando chrony y systemd-timesyncd para asegurar una sincronización horaria precisa.

## Configuración del Servidor NTP (FreeIPA)

### Paso 1: Instalar chrony
En el nodo donde se encuentra instalado FreeIPA (servidor con IP 10.17.3.11), instala chrony si no está instalado:

```bash
sudo dnf install chrony -y
```

Habilita y arranca el servicio de chronyd:

```bash
sudo systemctl enable chronyd --now
sudo systemctl start chronyd
```

Configura chrony para usar los servidores NTP correctos. Edita el archivo `/etc/chrony.conf`:

```bash
sudo nano /etc/chrony.conf
```

Asegúrate de agregar o modificar las siguientes líneas para usar servidores NTP públicos y la IP del servidor FreeIPA como fuente interna:

```ini
pool europe.pool.ntp.org iburst
server 10.17.3.11 iburst
```

Reinicia el servicio para aplicar los cambios:

```bash
sudo systemctl restart chronyd
```

Verifica el estado de la sincronización:

```bash
sudo chronyc sources -v
sudo systemctl status chronyd
```

### Paso 2: Configurar el Firewall
Habilita el puerto NTP (123) en el firewall:

```bash
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

### Paso 3: Verificar la Sincronización de la Hora
Verifica que el servicio de chrony está funcionando correctamente:

```bash
sudo chronyc sources -v
```

Asegúrate de que el puerto NTP está abierto:

```bash
sudo netstat -uln | grep :123
```

## Configuración de los Clientes NTP (Bootstrap, Master, Workers)

### Paso 1: Configurar systemd-timesyncd
En los nodos clientes (Bootstrap, Master, Workers), verifica y edita la configuración de systemd-timesyncd. Abre el archivo `/etc/systemd/timesyncd.conf`:

```bash
sudo nano /etc/systemd/timesyncd.conf
```

Modifica el archivo para incluir la IP del servidor NTP (FreeIPA):

```ini
[Time]
NTP=10.17.3.11
FallbackNTP=0.pool.ntp.org
```

Guarda los cambios y reinicia el servicio:

```bash
sudo systemctl restart systemd-timesyncd
```

Habilita systemd-timesyncd para que arranque al iniciar el sistema:

```bash
sudo systemctl enable systemd-timesyncd
```

```bash
core@bootstrap ~ $ timedatectl timesync-status
       Server: 10.17.3.11 (10.17.3.11)
Poll interval: 4min 16s (min: 32s; max 34min 8s)
         Leap: normal
      Version: 4
      Stratum: 3
    Reference: 50CB6EA9
    Precision: 1us (-24)
Root distance: 28.907ms (max: 5s)
       Offset: -5.016ms
        Delay: 599us
       Jitter: 4.721ms
 Packet count: 3
    Frequency: +20.993ppm
core@bootstrap ~ $
```

```bash
timedatectl show-timesync --all
```




### Paso 2: Verificar la Sincronización en los Clientes
Verifica el estado de la sincronización en los nodos clientes:

```bash
timedatectl status
```

Deberías ver algo similar a:

```bash
System clock synchronized: yes
NTP service: active
```

### Paso 3: Comprobación Final
Verifica que los nodos estén sincronizados correctamente con el servidor NTP (FreeIPA 10.17.3.11):

Realiza un ping desde cualquier cliente al servidor NTP:

```bash
ping -c 4 10.17.3.11
```

Usa `timedatectl` para verificar que el reloj del sistema esté sincronizado:

```bash
timedatectl status
```

## Guía para Verificación y Configuración de DNS en FreeIPA

### Paso 1: Comprueba la Resolución DNS
Después de haber configurado los reenviadores y reiniciado `named`, comprueba si la resolución DNS funciona correctamente.

```bash
# Verifica la resolución DNS con curl
curl https://google.com

# Verifica la resolución DNS con ping
ping google.com
```

### Paso 2: Verifica el Archivo `/etc/resolv.conf`
Es importante que el archivo `/etc/resolv.conf` esté correctamente configurado. Este archivo debe apuntar a tu servidor DNS local (FreeIPA) y, opcionalmente, a servidores DNS externos como Google DNS.

```bash
# Visualiza el contenido de /etc/resolv.conf
cat /etc/resolv.conf
```

El archivo debe verse similar a lo siguiente:

```bash
nameserver 127.0.0.1  # O la IP de tu servidor FreeIPA
nameserver 8.8.8.8  # Google DNS
```

Si el archivo no está correctamente configurado, edítalo:

```bash
# Edita /etc/resolv.conf
sudo nano /etc/resolv.conf
```

Agrega las siguientes líneas (modifica según sea necesario):

```bash
nameserver 127.0.0.1
nameserver 8.8.8.8
```

Guarda los cambios y cierra el archivo.

### Paso 3: Prueba la Conectividad Nuevamente
Una vez que hayas configurado correctamente el archivo `/etc/resolv.conf`, prueba de nuevo la resolución de nombres.

```bash
# Prueba la conectividad con curl
curl https://google.com

# Prueba la conectividad con ping
ping google.com
```

Si todo está correctamente configurado, deberías poder resolver los nombres de dominio sin problemas.

### Paso 4: Verifica los Logs si Persiste el Problema
Si el problema persiste, es recomendable revisar los logs de BIND para obtener más detalles sobre posibles errores de configuración de DNS.

```bash
# Verifica los logs del servicio named
sudo journalctl -u named
```

Los logs deberían proporcionar información adicional sobre cualquier fallo relacionado con la configuración de DNS en tu sistema.

---

Con esta guía puedes asegurar que la configuración de NTP y DNS en tu servidor FreeIPA esté correctamente establecida, y que los clientes estén correctamente sincronizados tanto en tiempo como en resolución de nombres.



roky linux

sudo dnf install chrony -y

sudo chronyc sources -v
sudo systemctl status chronyd

sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload


 sincronizar específicamente con 10.17.3.11, puedes modificar la configuración de tu archivo chrony.conf (ubicado típicamente en /etc/chrony.conf en Rocky Linux) para priorizar este servidor. Aquí tienes cómo hacerlo:
Editar el archivo chrony.conf:

bash
Copiar código
sudo vi /etc/chrony.conf
Agregar el servidor NTP prioritario (si no está ya en la lista):

bash
Copiar código
server 10.17.3.11 iburst prefer
Reiniciar el servicio chronyd:

bash
Copiar código
sudo systemctl restart chronyd
Verificar que 10.17.3.11 es el servidor NTP activo:

bash
Copiar código
sudo chronyc sources -v
Con este cambio, el servidor 10.17.3.11 será el preferido para la sincronización de tiempo en tu red.






