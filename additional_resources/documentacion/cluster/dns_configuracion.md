Pasos para Completar la Configuración
1. Alias DNS para los Balanceadores
En el servidor FreeIPA, configura los alias DNS para los balanceadores, los nodos de Kubernetes y la URL principal cefaslocalserver.com con las siguientes entradas:

bash
Copiar código
# Entradas para /etc/hosts o configuración del servidor DNS
10.17.3.12 loadbalancer1.cefaslocalserver.com
10.17.3.13 loadbalancer2.cefaslocalserver.com
10.17.4.21 master1.cefaslocalserver.com
10.17.4.22 master2.cefaslocalserver.com
10.17.4.23 master3.cefaslocalserver.com
10.17.4.31 worker1.cefaslocalserver.com
10.17.4.32 worker2.cefaslocalserver.com
10.17.4.33 worker3.cefaslocalserver.com

# Alias DNS para balanceadores con round-robin
cefaslocalserver.com -> 10.17.3.12, 10.17.3.13
2. Configuración del Servidor DNS (FreeIPA)
En el servidor FreeIPA (freeipa1.cefaslocalserver.com), realiza lo siguiente:

Accede a la interfaz de administración o usa comandos CLI para configurar las zonas DNS:

bash
Copiar código
ipa dnsrecord-add cefaslocalserver.com loadbalancer1 --a-rec 10.17.3.12
ipa dnsrecord-add cefaslocalserver.com loadbalancer2 --a-rec 10.17.3.13
ipa dnsrecord-add cefaslocalserver.com master1 --a-rec 10.17.4.21
ipa dnsrecord-add cefaslocalserver.com master2 --a-rec 10.17.4.22
ipa dnsrecord-add cefaslocalserver.com master3 --a-rec 10.17.4.23
ipa dnsrecord-add cefaslocalserver.com worker1 --a-rec 10.17.4.31
ipa dnsrecord-add cefaslocalserver.com worker2 --a-rec 10.17.4.32
ipa dnsrecord-add cefaslocalserver.com worker3 --a-rec 10.17.4.33

# Alias round-robin para balanceadores
ipa dnsrecord-add cefaslocalserver.com @ --a-rec 10.17.3.12 --a-rec 10.17.3.13
Reinicia el servicio DNS para aplicar los cambios:

bash
Copiar código
systemctl restart named-pkcs11.service
3. Configuración de CoreDNS en Kubernetes
Configura CoreDNS para reenviar consultas externas al servidor FreeIPA. Aplica la configuración a través de un ConfigMap:

Crea o actualiza el ConfigMap de CoreDNS:

yaml
Copiar código
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        forward . 10.17.3.11
        cache 30
        loop
        reload
        loadbalance
    }
Aplica el ConfigMap en el clúster:

bash
Copiar código
kubectl apply -f coredns-configmap.yaml
Reinicia los pods de CoreDNS:

bash
Copiar código
kubectl rollout restart deployment coredns -n kube-system
4. Validación de la Configuración
Consulta DNS desde el clúster Kubernetes:

Ejecuta lo siguiente desde un pod o nodo dentro del clúster:

bash
Copiar código
dig loadbalancer1.cefaslocalserver.com
dig cefaslocalserver.com
dig worker1.cefaslocalserver.com
Consulta DNS desde una máquina externa:

Asegúrate de que las consultas a cefaslocalserver.com apunten a los balanceadores correctamente.

Acceso a la aplicación NGINX:

Visita https://cefaslocalserver.com desde un navegador para verificar que el balanceo y los servicios funcionan correctamente.

Este flujo asegura que:

Alias DNS y balanceo round-robin están configurados en FreeIPA.
CoreDNS puede reenviar consultas externas a FreeIPA.
Kubernetes y balanceadores están correctamente configurados para manejar peticiones internas y externas.


Validación de DNS y CoreDNS
DNS en FreeIPA Ejecuta los siguientes comandos en FreeIPA para confirmar las entradas DNS:

bash
Copiar código
ipa dnsrecord-add cefaslocalserver.com loadbalancer1 --a-rec 10.17.3.12
ipa dnsrecord-add cefaslocalserver.com loadbalancer2 --a-rec 10.17.3.13
ipa dnsrecord-add cefaslocalserver.com @ --a-rec 10.17.3.12 --a-rec 10.17.3.13
CoreDNS ConfigMap Configura y aplica:

yaml
Copiar código
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
        }
        forward . 10.17.3.11
        cache 30
        loop
        reload
        loadbalance
    }