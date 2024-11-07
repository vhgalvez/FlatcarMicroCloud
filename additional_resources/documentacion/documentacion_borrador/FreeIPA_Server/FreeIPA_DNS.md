# Instalación de FreeIPA

## FreeIPA para Configuración de DNS

Una vez configurado el nombre de host y la resolución DNS, procede con la instalación de FreeIPA:

```bash
sudo yum install -y ipa-server ipa-server-dns
sudo ipa-server-install
```

Sigue las instrucciones en pantalla para completar la configuración de FreeIPA, incluyendo dominio y realm.

## Configuración del Servidor DNS en FreeIPA

1. Establece el nombre de host de FreeIPA:

```bash
    hostnamectl set-hostname ipa.example.com
```

2. Edita el archivo /etc/hosts para agregar la dirección IP y el hostname de tu servidor FreeIPA:

```bash
echo "192.168.120.10 ipa.example.com ipa" | sudo tee -a /etc/hosts
```

3. Configura y verifica el DNS en FreeIPA
Instala y configura el DNS durante la instalación de FreeIPA y verifica utilizando comandos como `dig` o `nslookup`.

Esta documentación técnica detalla los pasos para establecer un servidor de DNS usando Rocky Linux y FreeIPA, proporcionando una base sólida para servicios de red internos.


# Configuración de DNS en CEFAS Local Server

```bash
sudo hostnamectl set-hostname dns.cefaslocalserver.com
```
    
Agrega la dirección IP y el nombre de dominio al archivo `/etc/hosts`:
```bash
echo "10.17.3.17  dns.cefaslocalserver.com ipa" | sudo tee -a /etc/hosts
```



### Especificaciones del Servidor Físico

| Característica   | Especificación                       |
|------------------|--------------------------------------|
| OS               | Rocky Linux 9.3 (Blue Onyx) x86_64   |
| Host             | ProLiant DL380 G7                    |
| Kernel           | 5.14.0-362.24.1.el9_3.0.1.x86_64     |
| Virtualization   | KVM                                  |
| Packages         | 1235 (rpm)                             |
| Shell            | bash 5.1.8                             |
| Resolution       | 1024x768                               |
| Terminal         | /dev/pts/0                             |
| CPU              | Intel Xeon X5650 (24) @ 2.666GHz       |
| GPU              | AMD ATI 01:03.0 ES1000                 |
| Memory           | 1093MiB / 35904MiB                     |
| Disk             | 1.5TB / 3.0TB                          |

### Server Configuration Summary

## Server Specifications

- **OS:** Rocky Linux 9.3 (Blue Onyx)
- **Host:** ProLiant DL380 G7
- **Kernel:** 5.14.0-362.24.1.el9_3.0.1.x86_64
- **CPU:** Intel Xeon X5650 (24 cores) @ 2.666GHz
- **GPU:** AMD ATI 01:03.0 ES1000
- **Memory:** 1093MiB / 35904MiB
- **Resolution:** 1024x768
- **Shell:** bash 5.1.8
- **Packages:** 1235 (rpm)
- **Terminal:** /dev/pts/0

## Network Interfaces fisicas

| Interface | IP Address     | Netmask         | Broadcast       |
|-----------|----------------|-----------------|-----------------|
| enp3s0f0  | 192.168.0.24   | 255.255.255.0   | 192.168.0.255   |
| enp3s0f1  | 192.168.0.25   | 255.255.255.0   | 192.168.0.255   |
| enp4s0f0  | 192.168.0.20   | 255.255.255.0   | 192.168.0.255   |
| enp4s0f1  | 192.168.0.26   | 255.255.255.0   | 192.168.0.255   |

## Disk Configuration

- **/dev/sda:** 3.27 TiB
- **/dev/sdb:** 465.71 GiB
- **Logical Volume Management:**
  - **Root:** 100 GiB
  - **Swap:** 17.72 GiB
  - **Home:** 3 TiB

## Disk Partitions

| Device   | Start      | End        | Size       | Type           |
|----------|------------|------------|------------|----------------|
| /dev/sda1| 2048       | 4095       | 2048       | System         |
| /dev/sda2| 4096       | 2101247    | 2 GB       | Linux Filesystem|
| /dev/sda3| 2101248    | 6204170239 | ~2.89 TiB  | Linux Filesystem|

## Memory and Storage

- **Total Memory:** 35GiB
- **Free Memory:** 33GiB
- **Swap:** 17GiB

## Filesystem Usage

| Filesystem        | Size   | Used   | Available | Use% | Mounted on |
|-------------------|--------|--------|-----------|------|------------|
| /dev/mapper/rl-root| 100G   | 7.5G   | 93G       | 8%   | /          |
| /dev/sda2         | 1014M  | 718M   | 297M      | 71%  | /boot      |
| /dev/mapper/rl-home| 3.0T   | 25G    | ~3.0T     | 1%   | /home      |

This configuration provides a detailed view of the system setup, ensuring all elements are concisely documented for effective cluster management.
