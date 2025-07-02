# Configuración de SSH para Aceptar Automáticamente Claves de Host al Usar sudo

Cuando usas `sudo ssh`, la conexión SSH se ejecuta bajo el usuario root, por lo cual su configuración SSH es independiente de la del usuario principal (victory en este caso). Esto puede resultar en una solicitud de confirmación de autenticidad del host, aunque ya hayas configurado `.ssh/config` en tu usuario principal.

Sigue estos pasos para configurar SSH en root y evitar que solicite confirmación al conectarse a hosts nuevos.

## 1. Crear el Archivo de Configuración SSH para root

Primero, crea o edita el archivo de configuración SSH específico para root, ubicado en `/root/.ssh/config`.

```bash
sudo nano /root/.ssh/config
```

## 2. Agregar la Configuración para Aceptar Automáticamente Claves de Host

Dentro del archivo `/root/.ssh/config`, agrega las siguientes líneas para permitir que SSH acepte automáticamente las claves de host al usar `sudo`:

```plaintext
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
```

- `Host *`: Aplica esta configuración a todos los hosts.
- `StrictHostKeyChecking no`: Desactiva la solicitud de confirmación de autenticidad de host.
- `UserKnownHostsFile=/dev/null`: Evita almacenar las claves de host en `known_hosts`.

## 3. Guardar y Cerrar

Guarda los cambios en el archivo y cierra el editor (`nano`).

## 4. Verificar los Permisos del Archivo de Configuración

Para que SSH use la configuración correctamente, asegúrate de que el archivo `/root/.ssh/config` tenga permisos restringidos:

```bash
sudo chmod 600 /root/.ssh/config
```

## 5. Probar la Conexión

Intenta conectarte nuevamente usando `sudo ssh` para verificar que la configuración esté funcionando. Esta vez, SSH debería aceptar automáticamente la clave de host sin solicitar confirmación.

```bash
sudo ssh -i /root/.ssh/cluster_openshift/key_cluster_openshift/id_rsa_key_cluster_openshift core@10.17.4.21 -p 22
```

```bash
sudo ssh -i /root/.ssh/cluster_k3s/shared/id_rsa_shared_cluster core@10.17.3.11 -p 22
```


Con esta configuración en `/root/.ssh/config`, `sudo ssh` debería conectarse sin solicitar la confirmación de autenticidad de host para cada conexión nueva.

