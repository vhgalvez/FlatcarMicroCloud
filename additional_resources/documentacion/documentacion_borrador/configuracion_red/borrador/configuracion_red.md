# Documento de Configuración: Comunicación entre Redes NAT, Acceso HTTPS, y Conexión VPN Segura

Este documento cubre la configuración necesaria para asegurar la comunicación entre redes NAT y el servidor Bastion, así como la configuración de acceso HTTPS y la conexión segura VPN para la gestión del servidor físico y el clúster.

## 1. Comunicación entre Redes NAT y el Servidor Bastion

Para permitir la comunicación entre las redes NAT y el servidor Bastion, configuraremos el reenvío de paquetes y rutas estáticas en el servidor Bastion.

### Paso 1: Configuración del Reenvío de Paquetes en el Servidor Bastion

**Habilitar el reenvío de paquetes IPv4:**

```bash
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Agregar reglas de IPTables para permitir el tráfico entre interfaces:**

```bash
sudo iptables -A FORWARD -i br0 -o virbr0 -j ACCEPT
sudo iptables -A FORWARD -i virbr0 -o br0 -j ACCEPT
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

### Paso 2: Configuración de Rutas Estáticas

**Agregar rutas estáticas para cada red NAT:**


```bash
sudo ip route add 10.17.3.0/24 via 192.168.0.1
sudo ip route add 10.17.4.0/24 via 192.168.0.1
```


## 2. Acceso HTTPS y Conexión VPN Segura

Para asegurar el acceso HTTPS y una conexión segura para la gestión del servidor y el clúster, configuraremos un servidor VPN utilizando WireGuard y habilitaremos certificados SSL/TLS para servicios expuestos.


### Paso 1: Configuración de WireGuard VPN


**Instalar WireGuard:**

```bash
sudo dnf install epel-release -y
sudo dnf install wireguard-tools -y
```

**Configurar WireGuard en el Servidor Bastion:**


Crear el archivo de configuración `/etc/wireguard/wg0.conf` con el siguiente contenido:

```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <server-private-key>

[Peer]
PublicKey = <client-public-key>
AllowedIPs = 10.0.0.2/32
```

**Habilitar y iniciar el servicio WireGuard:**

```bash
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

**Verificar la conexión WireGuard:**

```bash
sudo wg
```
** nginx va en un Pods de okd ** 
### Paso 2: Configuración de Certificados SSL/TLS

**Generar y configurar certificados SSL/TLS utilizando Let's Encrypt:**

**Instalar Certbot:**


```bash
sudo dnf install certbot -y
```

**Obtener un certificado SSL para el dominio del servidor:**

```bash
sudo certbot certonly --standalone -d yourdomain.com
```

**Configurar el servicio expuesto para usar SSL/TLS:**

Ejemplo de configuración de Nginx para usar el certificado SSL:


Crear un archivo de configuración para Nginx en `/etc/nginx/conf.d/ssl.conf`:

```ini
server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    location / {
        proxy_pass http://localhost:your_service_port;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
**Reiniciar Nginx para aplicar los cambios:**


**sudo systemctl restart nginx**

sudo systemctl restart nginx


## 3. Configuración del Servidor DNS FreeIPA

### Paso 1: Instalación de FreeIPA

**Instalar FreeIPA Server:**

```bash
sudo dnf install freeipa-server -y
```



**Configurar FreeIPA Server:**

```bash
sudo ipa-server-install
```

Sigue las instrucciones del instalador para configurar el dominio, la contraseña del administrador, y otras configuraciones necesarias.

### Paso 2: Configuración del Servidor DNS en FreeIPA

**Habilitar y configurar el DNS durante la instalación de FreeIPA:**

Durante el proceso de instalación, selecciona la opción para configurar el servidor DNS y proporciona la información de zona necesaria.

**Verificar la configuración de DNS:**

Puedes verificar la configuración del servidor DNS y agregar registros DNS a través de la interfaz web de FreeIPA o usando las herramientas de línea de comandos de FreeIPA.

Para agregar un registro DNS, usa el siguiente comando:

```bash
ipa dnsrecord-add example.com test --a-rec 192.0.2.1+
```

Verificar los registros DNS:


```bash
ipa dnsrecord-find example.com
```


## 4. Conclusión
   
Este documento proporciona una guía completa para configurar la comunicación entre redes NAT, acceso HTTPS seguro, conexión VPN utilizando WireGuard, y la configuración de un servidor DNS utilizando FreeIPA. Con estos pasos, podrás asegurar la comunicación eficiente y segura dentro de tu infraestructura de red y clúster.



