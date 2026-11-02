# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| Propietario | `${ values.owner }` |
| Tipo de servicio | `${ values.serviceType }` |
| Lenguaje | Go 1.26 (net/http) |
| Versión de la plantilla | `${ values.templateVersion }` |
| Repositorio | `jh-platform-lab/${ values.name }` |

## Qué incluye este servicio

- Una API con `/health` y las rutas del formulario (net/http).
- Dockerfile para Kubernetes y Dockerfile para Lambda.
- CI en cada pull request y CD al fusionar en `main`.
- Terraform para el repositorio ECR, el rol de despliegue (OIDC) y, en Lambda, la función.
- Alertas y dashboard de New Relic como código.

## Rutas de la API

| Método | Ruta | Operación | Estado |
|---|---|---|---|
| GET | `/health` | `health` | Implementada |
{%- for api in values.apis %}
| ${{ api.method }} | `${{ api.path }}` | `${{ api.name }}` | 501 hasta implementar |
{%- endfor %}
