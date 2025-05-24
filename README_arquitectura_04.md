✅ Orden de Implementación del Proyecto
🔐 Generador de Clave SSH Compartida
generate_shared_ssh_key
⟶ Objetivo: Permitir conexión entre nodos y automatización de Ansible.

🕒 Sincronización de Tiempo (NTP/Chrony)
ansible-ntp-chrony-kubernetes
⟶ Fundamental para sincronización en etcd y certificados TLS.

🌐 Configuración de CoreDNS (infra-cluster)
ansible-CoreDNS-setup-Linux
⟶ DNS interno para facilitar resolución entre nodos y servicios.

⚖️ Balanceador HAProxy + Keepalived (2 VIPs)
ansible-k8s-ha-loadbalancer
⟶ Una VIP para tráfico API (6443) y otra para tráfico web (80/443).

☸️ Despliegue K3s HA con etcd
ansible-k3s-etcd-cluster
⟶ Instala K3s en modo HA usando etcd externo en nodos master.

🧩 Cambio a VIP en Master1 (bootstrap)
k3s-vip-switch-master1-bootstrap
⟶ Reconfigura master1 para redirigir hacia la VIP.

💾 Almacenamiento NFS + Longhorn
flatcar-k3s-storage-suite
⟶ Implementa NFS (para RWX) y Longhorn (para RWO, snapshots, backup).

🚪 Ingress Controller con Traefik
traefik-ansible-k3s-cluster
⟶ Traefik como Ingress Controller (v3.x), con certificados Let's Encrypt o SelfSigned.

🔐 Instalar Sealed Secrets (Bitnami)
⟶ Se instala dentro del clúster (solo una vez) para cifrar los Secrets vía kubeseal.
Pasos básicos:

Instala el controller con kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.3/controller.yaml

Obtén la clave pública con kubeseal --fetch-cert > pub-cert.pem

Usa kubeseal para generar secretos cifrados válidos solo en ese clúster.

Cifra los secretos necesarios para Jenkins, ArgoCD, etc., y guárdalos en GitHub.

📊 Stack de Monitoreo Avanzado (Prometheus + Grafana)
ansible-monitoring-stack
⟶ Con PVCs, Ingress protegido, y opcionalmente autenticación vía Sealed Secrets.

🚀 Automatización con ArgoCD
ArgoCD-ansible-kubernetes
⟶ Gestión GitOps con integración a repositorios GitHub. Puedes proteger admin password con SealedSecret.

🔄 CI/CD con Jenkins + Ansible
jenkins-ansible-playbook
⟶ Jenkins instalado vía Helm con Ingress, plugins y secretos básicos.

🚀 Resumen de Integración con GitHub + Sealed Secrets
Herramienta	¿Se recomienda usar Sealed Secret?	¿Cómo se integra?
Jenkins	✅ Sí	Secreto htpasswd para Ingress + credenciales de repos Git
ArgoCD	✅ Sí	argocd-secret (admin password) encriptado con SealedSecrets
Grafana	✅ Opcional	Para admin password o datasources sensibles
Prometheus	✅ Opcional	Para credenciales en scrape_configs si accede a endpoints protegidos
Longhorn	❌ No requerido por defecto	Se puede proteger dashboard con htpasswd + Ingress + secret estándar

🔐 ¿Dónde se guardan los secretos?
Los manifiestos cifrados (SealedSecret) se guardan en GitHub junto al resto del manifiesto Helm o K8s.

Solo el controller dentro del clúster puede desencriptarlos y crear Secret válidos.

Si el clúster se pierde, puedes restaurar los SealedSecrets desde GitHub, y serán válidos si la key privada no fue perdida.