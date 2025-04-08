# Contribuir a FlatcarMicroCloud

Gracias por tu interés en contribuir al proyecto **FlatcarMicroCloud**. Este es un entorno Kubernetes de alta disponibilidad, automatizado con Terraform y Ansible, optimizado para servidores físicos.

Este archivo describe las mejores prácticas para contribuir, mantener tu fork actualizado y colaborar efectivamente con la comunidad.

---

## 🚀 Flujo de Trabajo para Contribuir

1. **Haz un fork del repositorio original**:
   - En GitHub, haz clic en "Fork" para crear tu propia copia.

2. **Clona tu fork en local**:
   ```bash
   git clone https://github.com/tu-usuario/FlatcarMicroCloud.git
   cd FlatcarMicroCloud
   ```

3. **Agrega el repositorio original como remoto upstream**:
   ```bash
   git remote add upstream https://github.com/vhgalvez/FlatcarMicroCloud.git
   ```

4. **Crea una nueva rama para tu cambio**:
   ```bash
   git checkout -b feature/mi-cambio
   ```

5. **Haz tus cambios y súbelos a tu fork**:
   ```bash
   git add .
   git commit -m "Agrega nueva funcionalidad X"
   git push origin feature/mi-cambio
   ```

6. **Abre un Pull Request** hacia `main` en el repositorio original.

---

## 🔄 Mantener tu Fork Actualizado

Mantén tu fork sincronizado con el repositorio original para evitar conflictos:

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

---

## 📅 Convenciones del Proyecto

- Usa nombres de rama como `feature/...`, `fix/...` o `docs/...`
- Sigue las estructuras del proyecto y reutiliza roles existentes si es posible.
- Usa `ansible-lint` y `terraform fmt` para mantener la calidad del código.
- Mantén la documentación actualizada (README, comentarios, ejemplos).

---

## ✅ Buenas Prácticas para Pull Requests

- Describe claramente el cambio y el problema que soluciona.
- Referencia issues relacionados (si los hay).
- Divide los cambios grandes en varios PRs si es posible.
- Evita cambios no relacionados en un mismo commit o PR.

---

## 🧰 Infraestructura y Subproyectos Relevantes

Este repositorio se integra con varios módulos complementarios:

| Nombre del Repositorio | Propósito |
|-------------------------|-----------|
| [ansible-storage-cluster](https://github.com/vhgalvez/ansible-storage-cluster) | Configura volúmenes LVM y NFS para almacenamiento |
| [ansible-freeipa-dns-setup-rockylinux](https://github.com/vhgalvez/ansible-freeipa-dns-setup-rockylinux) | Configura FreeIPA como DNS y autenticación |
| [ansible-ntp-freeipa-kubernetes](https://github.com/vhgalvez/ansible-ntp-freeipa-kubernetes) | Configura NTP sincronizado con FreeIPA |
| [ansible-haproxy-keepalived](https://github.com/vhgalvez/ansible-haproxy-keepalived) | Configura balanceadores de carga con VIP |
| [ansible-k3s-etcd-cluster](https://github.com/vhgalvez/ansible-k3s-etcd-cluster) | Instala K3s en HA con etcd |
| [traefik-k8s-ingress-controller-ansible](https://github.com/vhgalvez/traefik-k8s-ingress-controller-ansible) | Instala y configura Traefik como Ingress Controller |

---

## 👨‍💼 Contacto

Para dudas, sugerencias o colaboración directa:

- Abre un [Issue](https://github.com/vhgalvez/FlatcarMicroCloud/issues)
- O crea un Pull Request

Gracias por aportar al ecosistema de infraestructura moderna y automatizada 🚀