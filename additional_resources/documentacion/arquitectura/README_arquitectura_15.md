## Arquitectura de Red y Servicios: FlatcarMicroCloud (KVM + Kubernetes)

🧩 Infraestructura Base

**Host de virtualización (físico):**

* IP: `192.168.0.40` (IP estática del host físico)
* Sistema base: Rocky Linux 9.5 con KVM/libvirt

**Puente de red principal:**

* `br0` — Interfaz bridge con esclava física, conectada a la LAN
* IP de `infra-cluster`: `192.168.0.30` (usada también como DNS y NTP)

**Redes internas NAT (libvirt):**

* `virbr_kube02`: `10.17.3.0/24` — balanceadores,
* `virbr_kube03`:`10.17.4.0/24` — nodos Kubernetes (masters, workers, storage) &#x20;
* `virbr_kube0`4:`10.17.5.0/24` — PostgreSQL&#x20;

  &#x20;

---

### 🌐 Acceso Externo: Redirección de Puertos

**Router SERCOM (192.168.0.1):**

| Servicio | IP Interna   | Protocolo | Puerto LAN | Puerto Público |
| -------- | ------------ | --------- | ---------- | -------------- |
| HTTP     | 192.168.0.30 | TCP       | 80         | 8080           |
| HTTPS    | 192.168.0.30 | TCP       | 443        | 2052           |

Esto permite:

* Desde fuera de tu red:

  * `http://TU_IP_PUBLICA:8080` → VIP `10.17.3.30:80` (redirección HAProxy)
  * `https://TU_IP_PUBLICA:2052` → VIP `10.17.3.30:443`
* Dentro de la red: `http://10.17.3.30` y `https://10.17.3.30`

`infra-cluster` actúa como puente entre la red LAN y los balanceadores del clúster.

---

### 🛡️ Balanceadores de Carga (HAProxy + Keepalived)

**VIPs definidos:**

* `10.17.3.10`: Tráfico API Kubernetes (`6443`)
* `10.17.3.30`: Tráfico HTTP/HTTPS web (`80/443`)

**Load Balancers:**

* `loadbalancer1`: 10.17.3.11
* `loadbalancer2`: 10.17.3.12
* `loadbalancer3`: 10.17.3.13

Los LBs comparten las IPs virtuales (VIPs) mediante Keepalived y balancean tráfico con HAProxy.

---

### ☸️ Clúster Kubernetes (K3s en Alta Disponibilidad)

**Masters:**

* `master1`: 10.17.4.21 — master1.cefaslocalserver.com
* `master2`: 10.17.4.22 — master2.cefaslocalserver.com
* `master3`: 10.17.4.23 — master3.cefaslocalserver.com

**Workers:**

* `worker1`: 10.17.4.24 — worker1.cefaslocalserver.com
* `worker2`: 10.17.4.25 — worker2.cefaslocalserver.com
* `worker3`: 10.17.4.26 — worker3.cefaslocalserver.com

**Storage:**

* `storage1`: 10.17.4.27 — Longhorn + NFS

Todos conectados a la red `10.17.4.0/24`.

---

### 🗄️ Base de Datos

**PostgreSQL:**

* `postgresql1`: 10.17.5.14
* Accesible por servicios internos y pods del clúster.
* Idealmente usa PVC desde NFS (`/srv/nfs/postgresql`)

---

### 🔐 Seguridad y Accesos

* Cloudflare + VPS (WireGuard) para exponer servicios públicamente.
* Firewall `nftables` reforzando las reglas del host físico.
* VIPs balanceadas con HAProxy + HTTPS.
* Comunicación segura mediante red privada, sin NAT ni doble enrutamiento.

---

### 🧠 Resumen Técnico

* Dominio: `socialdevs.site`
* DNS/NTP: nodo `infra-cluster` (`192.168.0.30`, bridge `br0`)
* Red del clúster: `10.17.4.0/24`
* Balanceo: HAProxy + Keepalived en red `10.17.3.0/24`
* VIPs: `10.17.3.10` (API), `10.17.3.30` (web)
* PostgreSQL: `10.17.5.14`
* Seguridad: WireGuard + Cloudflare + nftables
* Automatización: Terraform + Ansible

Esta arquitectura ofrece alta disponibilidad, visibilidad total, y acceso público seguro a los servicios de Kubernetes mediante un entorno virtualizado robusto en KVM/libvirt.
