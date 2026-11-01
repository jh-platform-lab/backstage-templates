# backstage-templates

Plantillas de autoservicio de Backstage para el reto técnico de Wenia. Cada plantilla genera un microservicio listo para trabajar.

## Plantillas

| Plantilla | Descripción |
|---|---|
| `python-service` | Microservicio en Python (FastAPI) o Node.js (Express), desplegable como AWS Lambda o en Kubernetes |

## Estructura

templates/<nombre>/template.yaml   # formulario, validación y pasos
templates/<nombre>/skeleton-common/  # archivos iguales para todos los lenguajes (Terraform, K8S, CD, observabilidad)
templates/<nombre>/skeleton-<lenguaje>/  # app, Dockerfile, pruebas y CI de cada lenguaje

## Cómo agregar una plantilla

1. Crear `templates/<nombre>/` con su `template.yaml` y sus carpetas `skeleton-*`.
2. Registrarla en el catálogo de Backstage.
3. Anotar el cambio en `CHANGELOG.md`.

Cada cambio de una plantilla va por pull request y sube la versión en `CHANGELOG.md`.
