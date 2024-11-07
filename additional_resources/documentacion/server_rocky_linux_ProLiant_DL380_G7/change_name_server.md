### Cambiar el nombre del host:

```bash
sudo hostnamectl set-hostname bastion1
```

Modificar el archivo `/etc/hosts`:

```bash
sudo nano /etc/hosts
```

Y luego cambia las líneas para que coincidan con el nuevo nombre:

```makefile

127.0.0.1 localhost bastion1

::1 localhost bastion1
```

- Reinicia el servidor para aplicar los cambios:

```bash
sudo reboot
```

- Después de reiniciar, tu prompt debería mostrar el nuevo nombre del host.