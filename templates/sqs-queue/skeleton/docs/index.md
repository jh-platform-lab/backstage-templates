# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| Equipo propietario | `${{ values.owner }}` |
| Versión de la plantilla | `${{ values.templateVersion }}` |

## Cómo trabajar con el recurso

| Qué | Dónde |
|---|---|
| Recurso y variables | `terraform/` (valores en `terraform.tfvars`) |
| Validación en cada PR | `.github/workflows/ci.yml`: fmt, validate y checkov |
| Aplicación | `.github/workflows/cd.yml`: `terraform apply` en `main`, con aprobación del entorno `production` |
| Detalle, variables y troubleshooting | README del repositorio |
