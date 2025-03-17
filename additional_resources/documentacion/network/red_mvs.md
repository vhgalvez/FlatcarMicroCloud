

# Red MVS freeIPA1 firewall-cmd

```bash
sudo firewall-cmd --zone=public --add-service=ssh --permanent
sudo firewall-cmd --zone=public --add-service=dns --permanent
sudo firewall-cmd --zone=public --add-service=dhcpv6-client --permanent
sudo firewall-cmd --zone=public --add-service=ntp --permanent
sudo firewall-cmd --zone=public --add-port=53/udp --permanent
sudo firewall-cmd --zone=public --add-port=53/tcp --permanent
sudo firewall-cmd --zone=public --add-source=10.17.4.0/24 --permanent
sudo firewall-cmd --zone=public --add-source=10.17.3.0/24 --permanent
sudo firewall-cmd --zone=public --set-target=ACCEPT --permanent
sudo firewall-cmd --reload
```


# Verificar configuración

```bash
sudo firewall-cmd --list-all
```

