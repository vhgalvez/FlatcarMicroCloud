✅ FLUJO COMPLETO DE DESPLIEGUE – FlatcarMicroCloud
🧠 Este flujo está diseñado para ejecutarse 100% con Terraform + Ansible, bajo una estrategia declarativa, modular y segura.

🔐 FASE 0 – Preparativos Iniciales
Paso	Descripción	Herramienta
0.1	Generar claves SSH compartidas para automatización	generate_shared_ssh_key
0.2	Configurar .ssh/config o variables en Terraform/Ansible	Manual / Ansible
0.3	Crear archivos base de redes virtuales (kube_network_*)	Terraform

🧱 FASE 1 – Infraestructura y Redes Virtuales
Paso	Descripción	Herramienta
1.1	Crear redes virtuales: nat_network_01/02/03	Terraform
1.2	Crear discos, VMs y recursos base (libvirt)	Terraform
1.3	Verificar IPs y acceso SSH con clave compartida	Ansible

⚙️ FASE 2 – Configuración Base de Nodos
Paso	Descripción	Herramienta
2.1	Configurar sincronización NTP con Chrony	ansible-ntp-chrony-kubernetes
2.2	Configurar DNS interno con CoreDNS	ansible-CoreDNS-setup-Linux

⚖️ FASE 3 – Balanceo y VIPs
Paso	Descripción	Herramienta
3.1	Instalar HAProxy + Keepalived con VIPs	ansible-k8s-ha-loadbalancer
3.2	Asignar VIPs: 10.17.5.10 (API), 10.17.5.30 (Ingress)	Keepalived

☸️ FASE 4 – Clúster Kubernetes (K3s)
Paso	Descripción	Herramienta
4.1	Desplegar K3s en modo HA (etcd)	ansible-k3s-etcd-cluster
4.2	Reconfigurar Master1 para usar el VIP	k3s-vip-switch-master1-bootstrap
4.3	Verificar con kubectl get nodes	Kubectl

💾 FASE 5 – Almacenamiento Persistente
Paso	Descripción	Herramienta
5.1	Configurar NFS en storage1	flatcar-k3s-storage-suite
5.2	Instalar Longhorn vía Helm	Helm + Ansible (dentro del repo)

🚪 FASE 6 – Ingress Controller
Paso	Descripción	Herramienta
6.1	Instalar Traefik como Ingress Controller	traefik-ansible-k3s-cluster
6.2	Configurar acceso con Secret / SealedSecret	k3s-secrets-cluster

🔐 FASE 7 – Gestión de Secretos
Paso	Descripción	Herramienta
7.1	Instalar Sealed Secrets Controller	k3s-secrets-cluster
7.2	Generar y cifrar secretos con kubeseal	kubeseal + Ansible
7.3	Subir SealedSecrets a repositorio Git privado	sealed-secrets-repo/

📊 FASE 8 – Monitorización y Logs
Paso	Descripción	Herramienta
8.1	Instalar Prometheus + Grafana con autenticación básica	ansible-monitoring-stack
8.2	Generar Secrets con htpasswd cifrado (Python + Ansible)	Ansible
8.3	(Opcional) ELK Stack y Alertmanager	Futuro

🚀 FASE 9 – GitOps con ArgoCD
Paso	Descripción	Herramienta
9.1	Instalar ArgoCD en el clúster K3s	ArgoCD-ansible-kubernetes
9.2	Configurar App-of-Apps, SealedSecrets, y microservicios	YAML + GitHub
9.3	Verificar sincronización automática	ArgoCD UI / CLI

🔄 FASE 10 – CI/CD con Jenkins + Docker Hub
Paso	Descripción	Herramienta
10.1	Instalar Jenkins en el clúster	jenkins-ansible-playbook
10.2	Crear Jenkinsfile para construir imágenes Docker	Docker + Jenkinsfile
10.3	Subir imágenes a Docker Hub o GHCR (autenticación mediante Secret)	Docker CLI / GHCR / Jenkins plugin
10.4	Hacer auto-commit a manifiestos de despliegue (GitOps con ArgoCD)	Jenkins + Git
10.5	ArgoCD detecta cambios y sincroniza automáticamente	Git + ArgoCD

🔐 Seguridad: Las credenciales de Docker Hub deben almacenarse como SealedSecrets antes del uso en Jenkins o ArgoCD.

🔁 FLUJO SECUENCIAL VISUAL
mermaid
Copiar
Editar
graph TD
  A[Terraform redes + VMs]
  B[Claves SSH + acceso Ansible]
  C[Balanceadores HA + VIPs]
  D[K3s HA]
  E[Almacenamiento Longhorn + NFS]
  F[Ingress Controller (Traefik)]
  G[Sealed Secrets]
  H[Stack de Monitoreo]
  I[ArgoCD GitOps]
  J[Jenkins CI + Docker Hub]

  A --> B --> C --> D --> E --> F --> G --> H --> I --> J