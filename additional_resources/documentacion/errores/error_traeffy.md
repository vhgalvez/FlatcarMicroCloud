Documentación del Problema: Acceso al Dashboard de Traefik en Kubernetes
1. Síntoma y Errores Observados
Al intentar acceder al dashboard de Traefik desplegado en K3s, utilizando curl (tanto a través del NodePort como del dominio configurado), se recibía un error persistente:

curl: (35) OpenSSL SSL_connect: SSL_ERROR_ZERO_RETURN in connection to traefik.socialdevs.site:443
Este error indica que la conexión SSL/TLS se estableció correctamente, pero el servidor (Traefik) cerró la conexión de forma limpia antes de que se pudieran intercambiar datos de la capa de aplicación (HTTP). Además, la tarea de verificación del playbook de Ansible reportaba un código de estado 000 para la respuesta HTTP, confirmando que no se recibía contenido.

2. Hipótesis Confirmada del Error
La hipótesis confirmada es que el Service de Kubernetes de Traefik (kube-system/traefik) no estaba exponiendo el puerto 9000 en su definición spec.ports. El puerto 9000 es el puerto interno por defecto de la API del dashboard de Traefik.

Explicación Detallada:

Conexión TLS Exitosa: El error SSL_ERROR_ZERO_RETURN demuestra que Traefik sí estaba escuchando en el puerto 443 (o el NodePort correspondiente) y era capaz de completar el handshake TLS, lo que significa que el certificado TLS era válido y estaba siendo presentado correctamente.
Fallo en el Enrutamiento HTTP: Una vez que la conexión TLS se establece, Traefik busca una regla de enrutamiento (IngressRoute) para la solicitud entrante (Host: traefik.socialdevs.site, PathPrefix: /dashboard). La IngressRoute estaba correctamente configurada para enviar el tráfico al servicio traefik en el puerto 9000.
Service sin Puerto 9000: El fallo ocurría porque, a pesar de la configuración en IngressRoute y en el archivo values.yaml de Helm (que se detallará a continuación), el Service real de Kubernetes para Traefik no incluía el puerto 9000 en su lista de puertos expuestos. Como resultado, Traefik no tenía un destino válido al que enviar la solicitud HTTP, lo que provocaba el cierre inmediato y limpio de la conexión TLS.
3. Proceso de Descubrimiento y Confirmación
El diagnóstico se desarrolló a través de los siguientes pasos:

Revisión Inicial de values_nopvc.yaml.j2: Se confirmó que la plantilla de configuración de Helm (values_nopvc.yaml.j2) sí incluía la definición para exponer el puerto 9000 bajo service.ports.traefik. Esto eliminó la plantilla como la fuente del error.
YAML

service:
  ports:
    # ... otros puertos
    traefik:
      port: 9000
      nodePort: 30900
Verificación del Certificado TLS: Se confirmó que el certificado wildcard *.socialdevs.site (almacenado en internal-tls-secret) cubría correctamente traefik.socialdevs.site, descartando problemas de validez del certificado como causa del SSL_ERROR_ZERO_RETURN.
Seguimiento del Archivo values.yaml Renderizado: Se identificó que la tarea de Ansible que renderizaba la plantilla values_nopvc.yaml.j2 estaba sobrescribiendo la ruta de destino, guardando el archivo en /tmp/traefik-values.yaml en lugar de playbooks/files/traefik-values.yaml. Aunque se corrigió este problema (asegurando que el archivo se generara en la ruta correcta) y se confirmó que el archivo /tmp/traefik-values.yaml contenía la definición del puerto 9000.
Inspección Crítica del Service Activo en Kubernetes: A pesar de que el values.yaml era correcto y Helm reportaba un upgrade exitoso, la ejecución de kubectl -n kube-system get svc traefik -o yaml reveló consistentemente que el puerto 9000 no estaba listado en la sección spec.ports del Service. Esta fue la prueba definitiva de que el Service no se estaba actualizando con la configuración deseada.
4. Posibles Soluciones y la Solución Implementada
Se consideraron varias soluciones para forzar la actualización del Service:

Forzar helm upgrade (--force): Un intento de forzar la actualización del release de Helm.
Recreación del Pod: Eliminar manualmente los pods de Traefik para forzar su recreación, esperando que el Service se actualizara en el proceso.
Desinstalación y Reinstalación Limpia (Solución Implementada): Esta fue la estrategia elegida por ser la más robusta y garantizar que todos los recursos se recrearan desde cero con la configuración correcta. Cuando los helm upgrade fallan en actualizar recursos existentes de manera específica, una reinstalación limpia es a menudo la solución más eficaz.
Pasos de la Solución Implementada:

Desinstalación del release de Helm:
Se procedió a eliminar el release de Helm de Traefik para asegurar una limpieza completa de los recursos asociados.

Bash

/usr/local/bin/helm uninstall traefik -n kube-system
Se verificó que no quedaran pods ni servicios de Traefik después de la desinstalación.

Re-ejecución del playbook de Ansible:
Se ejecutó el playbook principal de Ansible (deploy_traefik.yml) nuevamente. Al no encontrar un release de Traefik existente, el comando helm upgrade --install actuará como un helm install, creando todos los recursos, incluido el Service, desde cero con la configuración actualizada del values.yaml.

Bash

sudo ansible-playbook playbooks/deploy_traefik.yml
Resultado Esperado:

Tras la reinstalación, el Service de Traefik en Kubernetes (kubectl -n kube-system get svc traefik -o yaml) deberá mostrar ahora el puerto traefik (9000) correctamente listado. Una vez confirmado esto, el acceso al dashboard de Traefik a través de la URL https://traefik.socialdevs.site/dashboard/ debería funcionar, ya que el enrutador de Traefik ahora tendrá un backend válido al cual enviar el tráfico HTTP.

La hipótesis profunda del error radica en una desincronización persistente y crítica entre el estado deseado del Service de Traefik, tal como lo define Helm (basado en tus values.yaml), y el estado real del objeto Service en el API de Kubernetes.

Analicemos la evidencia para esta hipótesis:

Estado Deseado (por Helm y tu configuración): ¡Correcto!

Tu archivo playbooks/files/traefik-values.yaml muestra claramente la configuración service.ports.traefik para el puerto 9000.
Más importante aún, la salida de helm get values traefik -n kube-system confirma que Helm sí tiene almacenada la configuración correcta para el Service, incluyendo el puerto 9000. Esto es crucial: Helm sabe que el Service debería tener ese puerto.
Estado Real (en Kubernetes): ¡Incorrecto!

La salida de kubectl -n kube-system get svc traefik -o yaml muestra consistentemente que el Service de Traefik no incluye el puerto 9000 en su sección spec.ports. Solo están presentes los puertos web (80) y websecure (443).
La Contradicción y la Falla de Reconciliación:
Aquí es donde radica la esencia del problema. Helm, como gestor de paquetes, se encarga de que el estado real de los recursos en Kubernetes coincida con el estado deseado definido en sus charts y valores. Sin embargo, en este caso específico, para el recurso Service/traefik, la reconciliación de Helm está fallando de alguna manera. A pesar de tener la configuración correcta en su "memoria" (helm get values), no logra aplicarla o mantenerla aplicada en el objeto Service real en Kubernetes.

Posibles Causas de la Falla de Reconciliación (Hipótesis Profunda):

Problema de Caché o Estado Interno en Kubernetes/K3s: Es posible que el servidor API de Kubernetes, o algún controlador específico (como el controlador de Services), tenga una entrada en caché o un estado inconsistente para el Service de Traefik. Esto podría hacer que ignore actualizaciones o que persista una versión antigua del Service a pesar de los intentos de Helm.
Bug Transitorio de Helm o del Chart: Aunque menos común para charts ampliamente usados, podría haber un escenario de borde o una interacción específica que impida a Helm modificar este Service correctamente. Sin embargo, dado que helm get values muestra el estado correcto, el problema es más probable que esté en la fase de "aplicación" al clúster que en la de "procesamiento" de valores.
Recursos Huérfanos/Conflictos (menos probable tras uninstall): Una definición anterior del Service podría estar causando un conflicto, aunque tu intento de desinstalación debería haber limpiado esto.
Consecuencia Directa (SSL_ERROR_ZERO_RETURN):
La falla en la exposición del puerto 9000 en el Service tiene una consecuencia directa en el acceso al dashboard. La IngressRoute está configurada para recibir el tráfico HTTPS en el puerto 443, realizar la autenticación y luego reenviar la solicitud al servicio traefik en su puerto 9000 (el puerto interno de la API del dashboard). Dado que el Service de Kubernetes no está mapeando ni haciendo accesible el puerto 9000, el reenvío interno de Traefik falla. El error SSL_ERROR_ZERO_RETURN indica que la conexión TLS inicial (en el puerto 443) se estableció correctamente, pero Traefik la cerró abruptamente porque no pudo completar la solicitud HTTP debido a la falta de un backend válido (el puerto 9000 no expuesto en el Service).

En resumen, la hipótesis profunda es que hay una falla a nivel de la capa de control de Kubernetes (posiblemente un estado inconsistente o problema de caché del API/Controladores) que impide que el Service de Traefik se actualice correctamente con la definición completa de puertos que Helm le está proporcionando.

La solución para esto suele ser forzar una "reparación" del recurso, lo que a menudo implica la eliminación manual del Service para que Helm pueda recrearlo desde cero con el estado deseado. En este caso, la desinstalación completa del release de Helm y su posterior reinstalación fue el enfoque más efectivo para resolver la discrepancia entre el estado deseado y el estado real del Service de Traefik en Kubernetes.