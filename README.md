# backstage-templates

Plantillas de autoservicio de Backstage para el reto técnico de Wenia. Cada plantilla genera un microservicio listo para trabajar.

## Plantillas

| Plantilla | Descripción |
|---|---|
| `python-service` | Microservicio FastAPI, desplegable como AWS Lambda o en Kubernetes |

## Estructura

templates/<nombre>/template.yaml   # formulario, validación y pasos
templates/<nombre>/skeleton/       # archivos que se generan

## Cómo agregar una plantilla

1. Crear `templates/<nombre>/` con su `template.yaml` y su `skeleton/`.
2. Registrarla en el catálogo de Backstage.
3. Anotar el cambio en `CHANGELOG.md`.

Cada cambio de una plantilla va por pull request y sube la versión en `CHANGELOG.md`.
