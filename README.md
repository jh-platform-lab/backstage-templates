# backstage-templates

Plantillas de autoservicio de Backstage para el reto técnico de Wenia. Cada plantilla genera un microservicio listo para trabajar.

## Plantillas

| Plantilla | Descripción |
|---|---|
| `python-service` | Microservicio Python (FastAPI), desplegable como AWS Lambda o en Kubernetes |
| `nodejs-service` | Microservicio Node.js (Express), desplegable como AWS Lambda o en Kubernetes |
| `go-service` | Microservicio Go (net/http), desplegable como AWS Lambda o en Kubernetes |
| `java-service` | Microservicio Java 21 (Spring Boot), desplegable como AWS Lambda o en Kubernetes |
| `s3-bucket` | Infra: bucket S3 privado con KMS, versionado y TLS (Terraform, CI con checkov, CD con OIDC) |
| `sqs-queue` | Infra: cola SQS con DLQ, KMS y TLS (Terraform, CI con checkov, CD con OIDC) |
| `update-service` | Gestión: abre un PR en un servicio existente con los archivos de plataforma a la última versión |
| `add-observability` | Gestión: abre un PR en un servicio existente con alertas y dashboard de New Relic |
| `team-registration` | Gestión: abre un PR en wenia-platform que registra un equipo en `catalog/teams/` |

## Estructura

Cada plantilla es una carpeta autocontenida, y Backstage muestra una card por carpeta:

```
templates/<nombre>/template.yaml   # formulario, validación y pasos
templates/<nombre>/skeleton/       # todo lo que se genera (app, Dockerfile, CI/CD, Terraform, K8S, observabilidad)
```

## Cómo agregar una plantilla

1. Crear `templates/<nombre>/` con su `template.yaml` y su carpeta `skeleton/`. Backstage la descubre sola (`templates/*/template.yaml`).
2. Anotar el cambio en `CHANGELOG.md`.

Cada cambio de una plantilla va por pull request y sube la versión en `CHANGELOG.md`.
