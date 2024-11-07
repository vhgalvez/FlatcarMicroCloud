# Guía para la Generación y Organización de Certificados en un Clúster Kubernetes

Este documento proporciona todos los comandos necesarios para generar y organizar los certificados en la máquina `helper`, que servirá como el servidor web para distribuir los certificados a los diferentes nodos del clúster Kubernetes. Los pasos incluyen la generación de certificados únicos para cada nodo y los certificados compartidos que se distribuirán entre todos los nodos.

## 1. Crear la Estructura de Directorios

Primero, se debe crear la estructura de directorios donde se almacenarán los certificados:

```bash
sudo mkdir -p /usr/share/nginx/certificates/master1/kubelet
sudo mkdir -p /usr/share/nginx/certificates/master2/kubelet
sudo mkdir -p /usr/share/nginx/certificates/master3/kubelet
sudo mkdir -p /usr/share/nginx/certificates/worker1/kubelet
sudo mkdir -p /usr/share/nginx/certificates/worker2/kubelet
sudo mkdir -p /usr/share/nginx/certificates/worker3/kubelet
sudo mkdir -p /usr/share/nginx/certificates/bootstrap/kubelet

sudo mkdir -p /usr/share/nginx/certificates/shared/ca
sudo mkdir -p /usr/share/nginx/certificates/shared/apiserver
sudo mkdir -p /usr/share/nginx/certificates/shared/etcd
sudo mkdir -p /usr/share/nginx/certificates/shared/sa
sudo mkdir -p /usr/share/nginx/certificates/shared/apiserver-etcd-client
```

## 2. Generar el Certificado de la CA (Certificados Compartidos)


El certificado de la Autoridad Certificadora (CA) se genera una vez y se compartirá con todos los nodos:

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/ca/ca.key -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -nodes -key /usr/share/nginx/certificates/shared/ca/ca.key -subj "/CN=Kubernetes-CA" -days 3650 -out /usr/share/nginx/certificates/shared/ca/ca.crt
```

## 3. Generar Certificados Únicos para Cada Nodo


**Master1 (10.17.4.21)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/master1/kubelet/kubelet.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/master1/kubelet/kubelet.key -subj "/CN=kubelet-master1" -out /usr/share/nginx/certificates/master1/kubelet/kubelet.csr
openssl x509 -req -in /usr/share/nginx/certificates/master1/kubelet/kubelet.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/master1/kubelet/kubelet.crt -days 365
```

**Master2 (10.17.4.22)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/master2/kubelet/kubelet.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/master2/kubelet/kubelet.key -subj "/CN=kubelet-master2" -out /usr/share/nginx/certificates/master2/kubelet/kubelet.csr
openssl x509 -req -in /usr/share/nginx/certificates/master2/kubelet/kubelet.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/master2/kubelet/kubelet.crt -days 365
```


**Master3 (10.17.4.23)**
```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/master3/kubelet/kubelet.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/master3/kubelet/kubelet.key -subj "/CN=kubelet-master3" -out /usr/share/nginx/certificates/master3/kubelet/kubelet.csr
openssl x509 -req -in /usr/share/nginx/certificates/master3/kubelet/kubelet.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/master3/kubelet/kubelet.crt -days 365
```

**Worker2 (10.17.4.25)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/worker2/kubelet/kubelet.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/worker2/kubelet/kubelet.key -subj "/CN=kubelet-worker2" -out /usr/share/nginx/certificates/worker2/kubelet/kubelet.csr
openssl x509 -req -in /usr/share/nginx/certificates/worker2/kubelet/kubelet.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/worker2/kubelet/kubelet.crt -days 365
```



**Worker3 (10.17.4.26)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/worker3/kubelet/kubelet.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/worker3/kubelet/kubelet.key -subj "/CN=kubelet-worker3" -out /usr/share/nginx/certificates/worker3/kubelet/kubelet.csr
openssl x509 -req -in /usr/share/nginx/certificates/worker3/kubelet/kubelet.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/worker3/kubelet/kubelet.crt -days 365
```

# 4. Generar Certificados Compartidos



**API Server Certificate (Compartido entre Masters)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/apiserver/apiserver.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/shared/apiserver/apiserver.key -subj "/CN=kube-apiserver" -out /usr/share/nginx/certificates/shared/apiserver/apiserver.csr
openssl x509 -req -in /usr/share/nginx/certificates/shared/apiserver/apiserver.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/shared/apiserver/apiserver.crt -days 365
```

**Service Account Key Pair (Compartido entre Masters)**
```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/sa/sa.key -pkeyopt rsa_keygen_bits:2048
openssl rsa -in /usr/share/nginx/certificates/shared/sa/sa.key -pubout -out /usr/share/nginx/certificates/shared/sa/sa.pub
```

**Etcd Server Certificate (Compartido entre Masters)**


```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/etcd/etcd.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/shared/etcd/etcd.key -subj "/CN=etcd" -out /usr/share/nginx/certificates/shared/etcd/etcd.csr
openssl x509 -req -in /usr/share/nginx/certificates/shared/etcd/etcd.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/shared/etcd/etcd.crt -days 365
```

**API Server Etcd Client Certificates (Compartido entre Masters)**

```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client" -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.csr
openssl x509 -req -in /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.crt -days 365
```


**API Server Etcd Client Certificates (Compartido entre Masters)**
```bash
openssl genpkey -algorithm RSA -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -key /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.key -subj "/CN=apiserver-etcd-client" -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.csr
openssl x509 -req -in /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.csr -CA /usr/share/nginx/certificates/shared/ca/ca.crt -CAkey /usr/share/nginx/certificates/shared/ca/ca.key -CAcreateserial -out /usr/share/nginx/certificates/shared/apiserver-etcd-client/apiserver-etcd-client.crt -days 365
```







## 5. Configurar el Servidor Web para Servir los Certificados

Configura Nginx para servir los certificados:


```bash
cat <<EOF | sudo tee /etc/nginx/conf.d/certificates.conf
server {
    listen 80;
    server_name helper.cefaslocalserver.com;

    location / {
        root /usr/share/nginx/certificates;
        autoindex on;
    }
}
EOF

sudo systemctl restart nginx
```


## 6. Descargar los Certificados desde los Nodos



**Master1 (10.17.4.21)**

```bash
curl -O http://helper.cefaslocalserver.com/master1/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/master1/kubelet/kubelet.key
```

**Master2 (10.17.4.22)**

```bash
curl -O http://helper.cefaslocalserver.com/master2/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/master2/kubelet/kubelet.key
```

**Master3 (10.17.4.23)**
```bash
curl -O http://helper.cefaslocalserver.com/master3/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/master3/kubelet/kubelet.key
```


**Worker1 (10.17.4.24)**

```bash
curl -O http://helper.cefaslocalserver.com/worker1/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/worker1/kubelet/kubelet.key
```

**Worker2 (10.17.4.25)**
```bash
curl -O http://helper.cefaslocalserver.com/worker2/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/worker2/kubelet/kubelet.key
```

**Worker3 (10.17.4.26)**
```bash
curl -O http://helper.cefaslocalserver.com/worker3/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/worker3/kubelet/kubelet.key
```



**Bootstrap (10.17.4.27)**

```bash
curl -O http://helper.cefaslocalserver.com/bootstrap/kubelet/kubelet.crt
curl -O http://helper.cefaslocalserver.com/bootstrap/kubelet/kubelet.key
```


**Descargar Certificados Compartidos (para todos los nodos)**



```bash
curl -O http://helper.cefaslocalserver.com/shared/ca/ca.crt
curl -O http://helper.cefaslocalserver.com/shared/apiserver/apiserver.crt
curl -O http://helper.cefaslocalserver.com/shared/apiserver/apiserver.key
curl -O http://helper.cefaslocalserver.com/shared/sa/sa.key
curl -O http://helper.cefaslocalserver.com/shared/sa/sa.pub
curl -O http://helper.cefaslocalserver.com/shared/etcd/etcd.crt
curl -O http://helper.cefaslocalserver.com/shared/etcd/etcd.key
curl -O http://helper.cefaslocalserver.com/shared/etcd/ca.crt
curl -O http://helper.cefaslocalserver.com/shared/apiserver-etcd-client/apiserver-etcd-client.crt
curl -O http://helper.cefaslocalserver.com/shared/apiserver-etcd-client/apiserver-etcd-client.key
```









