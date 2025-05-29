# 🚀 Flujo de Instalación del Entorno FlatcarMicroCloud (Orden Recomendado)

Este documento describe el orden correcto de ejecución de los playbooks Ansible para desplegar completamente el entorno Kubernetes K3s HA con automatización GitOps, CI/CD, Ingress, monitoreo, y almacenamiento distribuido sobre bare metal.

---

| Etapa | Proyecto | Motivo de ejecución | Repositorio |
|-------|----------|----------------------|-------------|
| 1️⃣ | 🔐 **Generador de Clave SSH Compartida** | Base para acceso entre nodos (clave compartida para Ansible) | [generate_shared_ssh_key](https://github.com/vhgalvez/generate_shared_ssh_key) |
| 2️⃣ | 🌐 **Configuración de CoreDNS** | DNS interno funcional (para resolver nombres internos) | [ansible-CoreDNS-setup-Linux](https://github.com/vhgalvez/ansible-CoreDNS-setup-Linux) |
| 3️⃣ | 🕒 **Sincronización de Tiempo (NTP/Chrony)** | Evita errores de etcd y problemas con certificados TLS | [ansible-ntp-chrony-kubernetes](https://github.com/vhgalvez/ansible-ntp-chrony-kubernetes) |
| 4️⃣ | ⚖️ **Balanceador HAProxy + Keepalived** | Proporciona alta disponibilidad con IP virtual (VIP) para API y tráfico web | [ansible-k8s-ha-loadbalancer](https://github.com/vhgalvez/ansible-k8s-ha-loadbalancer) |
| 5️⃣ | ☸️ **Despliegue K3s HA con etcd** | Inicializa el clúster Kubernetes K3s en modo HA | [ansible-k3s-etcd-cluster](https://github.com/vhgalvez/ansible-k3s-etcd-cluster) |
| 6️⃣ | 🧩 **Cambio a VIP en Master1** | Hace que master1 utilice la VIP como servidor por defecto | [k3s-vip-switch-master1-bootstrap](https://github.com/vhgalvez/k3s-vip-switch-master1-bootstrap) |
| 7️⃣ | 🔐 **Configurar acceso remoto K8s** | Permite usar `kubectl` en localhost o estación de control | [ansible-k3s-configure-access](https://github.com/vhgalvez/ansible-k3s-configure-access) |
| 8️⃣ | 🔐 **Sealed Secrets (kubeseal)** | Instala controlador `Sealed Secrets` para cifrado de secretos desde ArgoCD | [ansible-SealedSecrets-kubeseal](https://github.com/vhgalvez/ansible-SealedSecrets-kubeseal) |
| 9️⃣ | 🚪 **Ingress Controller con Traefik (K3s)** | Ingress HTTP(S) para apps con autenticación básica (`htpasswd`) | [traefik-ansible-k3s-cluster](https://github.com/vhgalvez/traefik-ansible-k3s-cluster) |
| 🔟 | 💾 **Almacenamiento NFS + Longhorn** | Requiere clúster listo y DNS; proporciona almacenamiento persistente distribuido | [flatcar-k3s-storage-suite](https://github.com/vhgalvez/flatcar-k3s-storage-suite) |
| 1️⃣1️⃣ | 📊 **Stack de Monitoreo** | Observabilidad con Prometheus, Grafana, Alertmanager, etc. | [ansible-monitoring-stack](https://github.com/vhgalvez/ansible-monitoring-stack) |
| 1️⃣2️⃣ | 🚀 **Automatización con ArgoCD** | GitOps: aplica manifiestos desde Git al clúster K8s | [ArgoCD-ansible-kubernetes](https://github.com/vhgalvez/ArgoCD-ansible-kubernetes) |
| 1️⃣3️⃣ | 🔄 **CI/CD con Jenkins + Ansible** | Crea imágenes de microservicios y despliegue continuo vía Git y ArgoCD | [jenkins-ansible-playbook](https://github.com/vhgalvez/jenkins-ansible-playbook) |
| 1️⃣4️⃣ | 🐘 **PostgreSQL sobre NFS** | Base de datos para apps desplegadas, persistente sobre NFS + Longhorn | [postgres-ansible-nfs](https://github.com/vhgalvez/postgres-ansible-nfs) |

---

## ✅ Validaciones Importantes

- 🔐 **Sealed Secrets debe instalarse antes del Ingress Controller (Traefik)** si planeas usar secretos cifrados para credenciales `htpasswd` o tokens.
- 📡 **El acceso con `kubectl` desde el nodo de control debe validarse tras aplicar el cambio de VIP.**
- 🔄 **ArgoCD y Jenkins pueden funcionar en paralelo, pero Jenkins debe estar listo para generar las imágenes que ArgoCD desplegará.**

---

¿Deseas que esto lo convierta en un **repositorio central con README + diagrama visual** para documentarlo todo de forma oficial?
