# Solución para el error de instalación de FreeIPA

Problema:

El comando `ipa-server-install` falla debido a que la resolución del hostname no es correcta, ya que el hostname está resolviendo a `localhost (127.0.0.1/::1)` en lugar de la dirección IP real del servidor.

Pasos para solucionar:
Editar el archivo `/etc/hosts`:
Asegúrate de que el archivo `/etc/hosts` tenga la configuración correcta:

```bash
sudo nano /etc/hosts
```

Contenido del archivo `/etc/hosts`:

```bash
127.0.0.1   localhost.localdomain localhost
::1         localhost.localdomain localhost
10.17.3.11  freeipa1.cefaslocalserver.com freeipa1
```

Reiniciar NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

Verificar la resolución de nombres:

Asegúrate de que el hostname freeipa1.cefaslocalserver.com resuelva a la IP correcta.

```bash
ping -c 4 freeipa1.cefaslocalserver.com
```
El resultado debe mostrar que freeipa1.cefaslocalserver.com resuelve a 10.17.3.11.

Reiniciar la instalación de FreeIPA:

```bash
sudo ipa-server-install
```

Pasos detallados de la instalación:

Ejecuta el script de instalación:

```bash
sudo ipa-server-install
```

Responde las preguntas del script de instalación:

¿Deseas configurar el DNS integrado (BIND)? yes
Nombre de host del servidor: freeipa1.cefaslocalserver.com
Confirmar el nombre de dominio: cefaslocalserver.com
Proporcionar un nombre de realm: CEFASLOCALSERVER.COM
Contraseña del administrador de Directory Manager.
Contraseña del usuario admin de IPA.
Verifica la configuración del DNS:

```bash
dig freeipa1.cefaslocalserver.com
```

Si todos estos pasos se completan correctamente, el servidor FreeIPA debería instalarse y configurarse sin problemas. Si encuentras algún error, revisa los registros en `/var/log/ipaserver-install.log` para obtener más detalles sobre el problem