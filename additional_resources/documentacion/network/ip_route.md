### Plan de Ruteo y Conectividad entre Redes y Máquinas Virtuales

Este esquema asegura conectividad bidireccional entre las siguientes redes y la VM balanceadora `192.168.0.30`:

---

## ✅ OBJETIVO

Permitir que:

* Las redes privadas `10.17.3.0/24`, `10.17.4.0/24` y `10.17.5.0/24` puedan comunicarse entre sí y con `192.168.0.0/24`.
* La VM `k8s-api-lb (192.168.0.30)` tenga acceso a todas las redes internas y a internet.

---

## 🔹 EN EL SERVIDOR HOST (192.168.0.1)

### ✔️ Requisitos previos:

Habilitar el reenvío IP:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
sudo tee -a /etc/sysctl.conf <<< 'net.ipv4.ip_forward = 1'
sudo sysctl -p
```

### 🔌 Rutas:

```bash
sudo ip route add 10.17.3.0/24 dev virbr_kube02
sudo ip route add 10.17.4.0/24 dev virbr_kube03
sudo ip route add 10.17.5.0/24 dev virbr_kube03  # O interfaz equivalente
```

---

## 🚀 EN LA VM BALANCEADORA (`192.168.0.30`)

### ✅ Propósito:

Acceder a todas las redes privadas internas desde la VM `k8s-api-lb`.

### 🔌 Rutas:

Agrega estas rutas en `cloud-init` o manualmente:

```bash
ip route add 10.17.3.0/24 via 192.168.0.1 dev eth0
ip route add 10.17.4.0/24 via 192.168.0.1 dev eth0
ip route add 10.17.5.0/24 via 192.168.0.1 dev eth0
```

---

## 🚀 EN CADA VM DE LAS REDES PRIVADAS

### 🔌 Rutas necesarias:

Para que las VMs en `10.17.3.x`, `10.17.4.x` y `10.17.5.x` puedan responder a `192.168.0.30` y acceder a internet:

```bash
ip route add default via 10.17.X.1 dev eth0  # Asumiendo NAT saliente en host
ip route add 192.168.0.0/24 via 10.17.X.1 dev eth0
```

Reemplazar `X` por `3`, `4`, o `5` según corresponda.

---

## ⚡ RECOMENDACIÓN ADICIONAL

* Configurar `firewalld` para permitir ICMP, puertos `80`, `443`, `6443`, y `22`.
* Asegurarse que `NetworkManager` no sobrescriba rutas (usar `.nmconnection` si es necesario).

---

Con esta configuración todas las redes y máquinas podrán comunicarse bidireccionalmente y utilizar correctamente los VIPs, el DNS/NTP y los servicios del clúster K3s.
