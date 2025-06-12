¿Debo “abrir” (configurar) los NodePorts 32591 y 31541 en HAProxy para cada Ingress (local / público)?
No.
Esos dos NodePorts son únicos para el Service de Traefik, no para cada IngressRoute. Todas las rutas (locales y públicas) comparten el mismo punto de entrada L4:

Capa	Externo	HAProxy	Kubernetes -> Traefik	IngressRoute
L4	80 / 443	➜ 32591 / 31541	➜ Service traefik (NodePort)	(Reglas Host/Path que tu definas)

HAProxy

Sólo necesita dos frontends (80 y 443).

Sus backends apuntan una sola vez a los NodePorts 32591 (HTTP) y 31541 (HTTPS) que expone el Service traefik.

No importa cuántos IngressRoutes crees después: el tráfico sigue llegando por esos mismos backends.

Traefik Service (NodePort)

Mantiene esos puertos fijos porque los declaraste con nodePort: en el values.yaml.

Mientras no cambies esos números, todas las rutas siguen funcionando.

Ingress / IngressRoute

Viven en la capa L7.

Sólo definen reglas Host() / PathPrefix() y no tocan puertos TCP; por eso no necesitas abrir nada nuevo en HAProxy.

¿Cuándo tocarías los puertos de HAProxy?
Sólo si cambias el nodePort del Service traefik o despliegas otra instancia de Traefik escuchando en NodePorts distintos.

Para cualquier otro Ingress adicional (Grafana, ArgoCD, etc.) no se añaden backends nuevos en HAProxy.

Buenas prácticas rápidas
Tarea	Sugerencia
Fijar NodePorts	Déjalos “hard-coded” en values.yaml (web: nodePort: 32591, websecure: nodePort: 31541) para que no cambien entre despliegues.
Firewall externo	Asegúrate de permitir 80/443 hacia la VIP (192.168.0.33) y, dentro del propio nodo HAProxy, habilitar la salida hacia workerN:32591/31541.
Nuevos Ingress	Solo agrega/actualiza IngressRoute → Traefik hace el enrutamiento; HAProxy no se toca.

Con eso tu infraestructura queda limpia: un balanceo L4 (80->32591, 443->31541) y todo el ruteo L7 centralizado en Traefik.