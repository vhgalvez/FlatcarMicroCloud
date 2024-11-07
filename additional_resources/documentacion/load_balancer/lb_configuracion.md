

```bash
version: "3"

services:
  traefik:
    image: traefik:v3.1
    command:
      - --api.insecure=true
      - --providers.docker
      - --entrypoints.http.address=:80
      - --entrypoints.https.address=:443
      - --certificatesresolvers.myresolver.acme.email=your-email@example.com
      - --certificatesresolvers.myresolver.acme.storage=acme.json
      - --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=http
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/traefik/traefik.toml:/traefik.toml
      - /etc/traefik/acme.json:/acme.json
    restart: always
```


```bash
[entryPoints]
  [entryPoints.web]
    address = ":80"
  [entryPoints.websecure]
    address = ":443"
  [entryPoints.k8sApi]
    address = ":6443"

[api]
  dashboard = true
  insecure = true

[providers.docker]
  endpoint = "unix:///var/run/docker.sock"
  exposedByDefault = false

[log]
  level = "DEBUG"

[accessLog]

[certificatesResolvers.myresolver.acme]
  email = "your-email@example.com"
  storage = "acme.json"
  [certificatesResolvers.myresolver.acme.httpChallenge]
    entryPoint = "web"

[http.routers]
  [http.routers.api]
    entryPoints = ["websecure"]
    service = "api@internal"
    rule = "Host(`load_balancer1.cefaslocalserver.com`)"
  [http.routers.k8sApi]
    entryPoints = ["k8sApi"]
    service = "k8sApi"
    rule = "Host(`api.okd-cluster.cefaslocalserver.com`)"

[http.services]
  [http.services.api.loadBalancer]
    [[http.services.api.loadBalancer.servers]]
      url = "http://10.17.4.21:6443"
    [[http.services.api.loadBalancer.servers]]
      url = "http://10.17.4.22:6443"
    [[http.services.api.loadBalancer.servers]]
      url = "http://10.17.4.23:6443"
```