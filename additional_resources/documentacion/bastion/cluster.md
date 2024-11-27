Paso a Paso: Instalar kubectl y Configurar el Nodo Bastion
1. Descarga e Instalación de kubectl
Descargar el binario de kubectl: Descarga la versión compatible con tu clúster K3s (en este caso, v1.31.2):

bash
Copiar código
curl -LO "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl"
Verificar el archivo descargado (opcional): Descarga el archivo de verificación sha256 y comprueba la integridad del binario:

bash
Copiar código
curl -LO "https://dl.k8s.io/release/v1.31.2/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
Si el archivo es válido, deberías ver:

makefile
Copiar código
kubectl: OK
Hacer el binario ejecutable:

bash
Copiar código
chmod +x kubectl
Mover el binario a una ubicación del sistema:

bash
Copiar código
sudo mv kubectl /usr/local/bin/
Verificar la instalación de kubectl:

bash
Copiar código
kubectl version --client
Debe mostrar la versión del cliente de kubectl. Por ejemplo:

arduino
Copiar código
Client Version: v1.31.2
2. Configuración del Acceso al Clúster
Copia el archivo kubeconfig desde un nodo maestro: Desde el nodo master1, master2, o master3, copia el archivo kubeconfig al nodo Bastion:

bash
Copiar código
scp root@master1:/etc/rancher/k3s/k3s.yaml ~/.kube/config
Ajusta los permisos del archivo: Asegúrate de que el archivo tenga los permisos correctos para evitar problemas de acceso:

bash
Copiar código
chmod 600 ~/.kube/config
Editar el archivo kubeconfig: Abre el archivo ~/.kube/config con un editor de texto y actualiza el campo server para apuntar a la IP del balanceador de carga o a la IP de uno de los nodos maestros accesibles desde Bastion. Por ejemplo:

yaml
Copiar código
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: <data>
    server: https://192.168.0.21:6443 # Cambiar IP aquí
  name: default
Establece la variable de entorno KUBECONFIG: Exporta la variable KUBECONFIG para que kubectl utilice el archivo correcto:

bash
Copiar código
export KUBECONFIG=~/.kube/config
Para hacerlo persistente, agrega la línea a tu archivo ~/.bashrc:

bash
Copiar código
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
Prueba la conectividad al clúster: Usa el siguiente comando para verificar que kubectl puede comunicarse con tu clúster K3s:

bash
Copiar código
kubectl get nodes
Deberías ver una lista de todos los nodos en tu clúster con su estado:

css
Copiar código
NAME                           STATUS   ROLES                       AGE    VERSION
master1.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
master2.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
master3.cefaslocalserver.com   Ready    control-plane,etcd,master   5d8h   v1.31.2+k3s1
worker1.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
worker2.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
worker3.cefaslocalserver.com   Ready    <none>                      5d8h   v1.31.2+k3s1
Notas Importantes
Asegúrate de que el nodo Bastion tiene conectividad de red hacia el balanceador de carga o los nodos maestros.
Verifica que el puerto 6443 (puerto de la API de Kubernetes) esté accesible desde el nodo Bastion.
Si encuentras problemas, verifica los logs en el nodo maestro (/var/log/k3s-server.log) o la conectividad con ping y telnet.
¡Con esto tendrás kubectl configurado en tu nodo Bastion y listo para gestionar tu clúster! 🚀