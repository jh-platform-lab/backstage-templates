# Changelog

## 1.6.2 (go-service)

- Lambda: la imagen final de `Dockerfile.lambda` pasa de `distroless/static` a `amazonlinux:2023-minimal`. Con distroless la funcion fallaba al iniciar (`Runtime.InvalidEntrypoint`, 502 en la Function URL). Verificado en AWS: `/health` responde 200.

## 1.6.1 (go-service, java-service)

- go-service: Go 1.24 -> 1.26 (go.mod y Dockerfiles). `govulncheck` del CI marcaba 20 CVE de la libreria estandar de 1.24.
- java-service: Spring Boot 3.5.6 -> 3.5.16. Trivy del CI marcaba CVE HIGH en Spring Framework y Jackson.

## s3-bucket, sqs-queue (fix)

- CD: `hashicorp/terraform:1.12` ya no trae `sh` como entrypoint, asi que `docker run ... sh -c` fallaba con `Terraform has no command named "sh"`. Ahora usa `--entrypoint sh`, igual que `python-service` y `nodejs-service`. Verificado aplicando y destruyendo ambos skeletons renderizados en AWS.

## 1.6.0 (go-service)

- CD alineado con `python-service`: Terraform con modulos locales (`ecr-repo`, `github-cd-role`, `lambda-service`) y estado remoto en S3 por servicio; el primer `apply` (`-target=module.ecr -target=module.cd_role`) crea ECR y el rol antes de publicar la imagen; la Lambda se crea con la imagen ya publicada.
- `docker build --provenance=false --sbom=false` para que Lambda acepte la imagen.
- Kubernetes: `scripts/kind-deploy.sh --ecr [tag]` baja la imagen de ECR y la despliega en Kind (`wenia-eks`); el CD deja el comando en el resumen del run.

## 1.6.0 (java-service)

- CD alineado con `python-service`: Terraform con modulos locales y estado remoto en S3 por servicio; el primer `apply` crea ECR y el rol antes de publicar la imagen; la Lambda se crea con la imagen ya publicada. `--provenance=false --sbom=false` en el build.
- Lambda: memoria 1024 MB y timeout 30 s por defecto (la JVM arranca lento en frio con 256 MB y 10 s).
- Kubernetes: `scripts/kind-deploy.sh --ecr [tag]` baja la imagen de ECR y la despliega en Kind (`wenia-eks`).

## 1.7.0 (python-service), 1.6.3 (nodejs-service)

- Kubernetes: `scripts/kind-deploy.sh --ecr [tag]` baja de ECR la imagen publicada por el CD y la despliega en un cluster Kind (`wenia-eks`), simulando EKS. El CD deja el comando en el resumen del run. El cluster por defecto pasa de `local-dev` a `wenia-eks`.

## 1.6.7 (python-service), 1.6.2 (nodejs-service), 1.5.5 (go-service, java-service)

- Terraform: los permisos publicos de la Function URL usan identificadores propios (`WeniaUrlPublicAccess`, `WeniaUrlInvokeFunction`). Al crear una URL con auth `NONE`, Lambda agrega por su cuenta dos permisos con los nombres `FunctionURLAllowPublicAccess` y `FunctionURLAllowInvokeAction`; si Terraform pedia los mismos nombres a la vez, el que llegaba segundo recibia `409 ResourceConflictException` y el provider reintentaba 5 minutos antes de fallar el primer `apply`. Con nombres distintos no hay carrera. Los servicios ya generados no cambian solos: el fallo solo ocurre en el primer `apply`.

## 1.6.1 (nodejs-service)

- Imagen: se elimina npm/npx de la imagen final. El npm de la imagen base `node:24-slim` empaqueta `undici` y `brace-expansion` con CVE HIGH que hacían fallar el job `image` (Trivy) del CI en servicios nuevos.

## 1.6.0 (nodejs-service)

- CD alineado con `python-service`: el primer `terraform apply` (`-target=module.ecr -target=module.cd_role`) crea el repositorio ECR y el rol antes de publicar la imagen; la Lambda se crea con la imagen ya publicada. Corrige "The repository ... does not exist" en el primer despliegue.
- Terraform con módulos locales (`ecr-repo`, `github-cd-role`, `lambda-service`) y estado remoto en S3 por servicio.
- `docker build --provenance=false --sbom=false` para que Lambda acepte la imagen.
- Kubernetes: mismo despliegue simulado en Kind con `scripts/kind-deploy.sh --ecr`.

## 1.6.6 (python-service)

- Terraform: el repositorio ECR trae una política que permite a Lambda leer la imagen (`BatchGetImage`, `GetDownloadUrlForLayer`), acotada a la función del servicio. Sin ella `CreateFunction` falla con "Lambda does not have permission to access the ECR image".

## 1.6.5 (python-service)

- CD: `docker build --provenance=false --sbom=false`. Con las atestaciones por defecto la imagen se publica como índice de manifiestos y Lambda la rechaza ("image manifest, config or layer media type ... is not supported").

## 1.6.4 (python-service)

- CD: el primer `terraform apply` (ECR y rol) usa `-target=module.ecr -target=module.cd_role`. Sin el target, `image_uri` vacío ponía `count=0` en el módulo Lambda y un reintento (o un segundo despliegue) destruía la Lambda y su rol.

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
