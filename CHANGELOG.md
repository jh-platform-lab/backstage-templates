# Changelog

## 1.6.3 (python-service)

- CI: job `kind` que despliega los manifiestos en un cluster Kind dentro del runner y prueba `/health`. La documentación aclara que el despliegue real a EKS es el siguiente paso.

## 1.6.2 (python-service)

- Corrige el comando de Terraform: se quita el `sh` sobrante después de la imagen (el entrypoint ya es `sh`).

## 1.6.1 (python-service)

- Corrige la ejecución de Terraform en CI y CD: la imagen `hashicorp/terraform` tiene `terraform` como entrypoint, así que los comandos `sh -c` se ejecutan con `--entrypoint sh`.

## 1.6.0 (python-service)

- Terraform con módulos locales (`modules/ecr-repo`, `modules/github-cd-role`, `modules/lambda-service`) y backend remoto S3 con bloqueo por archivo.
- CI: `terraform plan` de solo lectura en cada PR (rol de plan por OIDC), actionlint y build estricto de TechDocs.
- CD en `main` con entorno `production`: `terraform apply` de ECR y rol, publicación de la imagen con su SHA, creación de la Lambda con esa imagen y actualización de código.
- Pendiente: replicar este flujo en nodejs-service, go-service y java-service.

## 1.5.4

- La entidad API tiene su propio sitio de TechDocs (`api-docs/`): muestra solo la referencia de la API (rutas, ejemplos y contrato), no la documentación del servicio.

## 1.5.3

- Los diagramas de arquitectura de TechDocs ahora son imágenes SVG (antes eran bloques Mermaid que Backstage mostraba como código). Se elige el diagrama según el tipo de servicio: Lambda o Kubernetes.

## 1.5.2

- La entidad API del catálogo lleva la anotación `backstage.io/techdocs-ref`, así que la API también muestra su documentación de TechDocs.

## 1.5.1

- Corrige la tabla de propiedades de la documentación: las variables del formulario se mostraban sin reemplazar.
- Nueva página **APIs** en la documentación de los servicios: cada ruta con su ejemplo en `curl` y la verificación de `/health`.

## 1.5.0

- Documentación TechDocs completa en los servicios Python, Node.js, Go y Java: arquitectura con diagramas Mermaid, desarrollo y verificación, operación y CI/CD, troubleshooting, observabilidad y evolución de la plantilla.
- Los servicios ya creados no reciben estas páginas; se añaden con `update-service` (pendiente de extender a esa plantilla).

## 1.4.0

- Documentación TechDocs en cada servicio y plantilla de infraestructura: `mkdocs.yml` (usa el README como página) y la anotación `backstage.io/techdocs-ref` en `catalog-info.yaml`. Los servicios ya creados no la reciben; se añade con `update-service`.

## 1.3.0

- Nuevas plantillas de servicio: `go-service` (net/http, imagen distroless) y `java-service` (Spring Boot 3.5, Java 21). Lambda usa AWS Lambda Web Adapter.
- Nuevas plantillas de infraestructura: `s3-bucket` (KMS, versionado, TLS, expiración) y `sqs-queue` (DLQ, redrive, KMS, TLS). Terraform con CI (fmt, validate, checkov) y CD con OIDC.
- Plantillas de gestión sobre servicios existentes: `update-service` (archivos de plataforma), `add-observability` (New Relic) y `team-registration` (Group en `catalog/teams/`). Abren un pull request; no crean repositorios.
- `python-service` y `nodejs-service` pasan a la versión 1.3.0 de la plantilla (sin cambios en el contenido generado).

## 1.2.0

- Una card por plantilla: `python-service` (FastAPI) y `nodejs-service` (Express), cada una en su carpeta autocontenida (`template.yaml` + `skeleton/`). Desaparece el campo `language` del formulario.
- Se eliminan `skeleton-common`, `skeleton-python` y `skeleton-nodejs`; el contenido generado no cambia.

## 1.1.0

- Nuevo lenguaje: Node.js 24 (Express). El campo `language` acepta `python` o `nodejs`.
- El skeleton se divide en `skeleton-common` (Terraform, K8S, CD, observabilidad, catálogo, OpenAPI), `skeleton-python` y `skeleton-nodejs`. La plantilla genera en tres pasos y los de lenguaje llevan `if`.
- Tipo `k8s` con manifiestos reales (`k8s/`) y `scripts/kind-deploy.sh` para probarlo en Kind.
- Nota: el agente de New Relic para Node no arranca sin licencia, por eso se activa solo si existe `NEW_RELIC_LICENSE_KEY`.

## 1.0.0

- Plantilla inicial `python-service`: formulario con validación, creación del repo y registro en el catálogo.
