# Documento Técnico: Proyecto CI/CD con Microservicios en K3s

## Objetivo General

Implementar un entorno de integración y entrega continua (CI/CD) para una arquitectura de microservicios sobre un clúster Kubernetes (K3s), utilizando herramientas modernas como Jenkins, ArgoCD, Redpanda, RabbitMQ, Nginx, Vue.js, FastAPI, PostgreSQL y almacenamiento persistente con NFS y Longhorn.

---

## Repositorios del Proyecto

### 1. `microservices-infra`

Infraestructura base para el clúster K3s:

- Jenkins (CI)
- ArgoCD (CD)
- Traefik (Ingress)
- Redpanda (Kafka-like)
- RabbitMQ
- Storage: NFS + Longhorn
- Longhorn replicados en los Workers
- Ansible para provisionamiento seguro de almacenamiento

### 2. `microservices-apps`

Repositorio GitOps:

- Contiene manifiestos YAML/Helm de todos los microservicios y servicios
- Usado por ArgoCD para sincronizar despliegues

### 3. `producer-service`

Microservicio FastAPI que produce eventos:

- Publica en Redpanda
- RabbitMQ para comunicación entre servicios
- CI/CD con Jenkins + GHCR

### 4. `consumer-service`

Microservicio FastAPI que consume eventos:

- Lee desde Redpanda y RabbitMQ
- CI/CD con Jenkins + GHCR

### 5. `frontend-vue-service`

Aplicación web Vue.js:

- Se construye con `npm run build`
- CI/CD con Jenkins + GHCR

### 6. `nginx-web-server`

Servidor Nginx como microservicio:

- Sirve el frontend desde volumen NFS
- Expone la app pública vía Traefik

---

## Tecnologías utilizadas

- **Kubernetes (K3s)**: Clúster ligero, con alta disponibilidad
- **Jenkins**: Automatización de CI
- **ArgoCD**: GitOps y despliegue automático
- **Redpanda**: Reemplazo liviano de Kafka para eventos
- **RabbitMQ**: Sistema de colas para tareas asíncronas
- **FastAPI**: Backend ligero y rápido para microservicios
- **Vue.js**: Frontend moderno y flexible
- **Nginx**: Servidor web para archivos estáticos
- **PostgreSQL (externo)**: Base de datos
- **NFS + Longhorn**: Almacenamiento persistente
- **GHCR**: Registro de contenedores gratuito (GitHub Container Registry)

---

## Estructura de almacenamiento

- `/srv/nfs/postgresql`: Volumen compartido para DB
- `/srv/nfs/shared`: Archivos comunes (frontend, logs, etc.)
- `/mnt/longhorn-disk`: Volúmenes RWO de apps

Provisionado con Ansible:

- `flatcar-k3s-storage-suite`
- Roles: `storage_setup`, `longhorn_worker`, `install_longhorn.yml`

---

## Flujo CI/CD completo

1. **Desarrollador hace un "push" a GitHub** (código microservicio)
2. **Jenkins** construye la imagen del contenedor y la sube a GHCR.
3. **Jenkins** actualiza el repositorio `microservices-apps` con el nuevo tag de imagen.
4. **ArgoCD** detecta el cambio y sincroniza el despliegue.
5. **K3s** despliega la nueva versión del microservicio.

---

## Checklist de Tareas

### Infraestructura Base

- [ ] Configurar K3s en nodos master y worker.
- [ ] Configurar acceso a K3s (`kubeconfig`).
- [ ] Provisionar almacenamiento persistente (NFS + Longhorn).
- [ ] Configurar VPN con WireGuard (si es necesario).
- [ ] Asegurar las reglas de red con `nftables`.

### Servicios internos

- [ ] Desplegar Redpanda y RabbitMQ con Helm.
- [ ] Instalar Prometheus y Grafana con almacenamiento persistente.
- [ ] Configurar PostgreSQL externo.
- [ ] Instalar Traefik como Ingress Controller.

### Microservicios

- [ ] Crear `producer-service` en FastAPI con publicación en Redpanda y RabbitMQ.
- [ ] Crear `consumer-service` en FastAPI con consumo desde Redpanda y RabbitMQ.
- [ ] Crear `frontend-vue-service` con Vue.js y Nginx.
- [ ] Configurar `nginx-web-server` para servir frontend desde volumen NFS.

### CI/CD

- [ ] Configurar Jenkins con pipelines para cada microservicio.
- [ ] Subir imágenes a GHCR.
- [ ] Actualizar manifiestos en el repo `microservices-apps` para despliegue en ArgoCD.

### Observabilidad (Opcional)

- [ ] Integrar Prometheus y Grafana para monitoreo.
- [ ] Configurar cAdvisor para contenedores.

### Documentación y Portafolio

- [ ] Crear `README.md` para cada repositorio con instrucciones.
- [ ] Agregar diagramas de arquitectura y flujo de CI/CD.
- [ ] Capturas de Jenkins y ArgoCD funcionando.

---

## Licencia

MIT License - Reutilizable para portafolios, proyectos educativos o pruebas técnicas profesionales.

---

Este es el **documento completo** que cubre todos los aspectos del proyecto CI/CD con microservicios sobre K3s. Puedes usarlo para seguir paso a paso la implementación, desde la infraestructura hasta el despliegue y la gestión de aplicaciones.

Si necesitas más detalles o alguna sección en específico, avísame y con gusto te ayudo a completar el proyecto.