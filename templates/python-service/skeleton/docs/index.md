# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| Equipo propietario | `${{ values.owner }}` |
| Tipo de servicio | `${{ values.serviceType }}` |
| Versión de la plantilla | `${{ values.templateVersion }}` |

## Rutas de la API

| Método | Ruta | Operación |
|---|---|---|
| GET | `/health` | `health` |
{%- for api in values.apis %}
| ${{ api.method }} | `${{ api.path }}` | `${{ api.name }}` |
{%- endfor %}

Cada ruta responde `501 Not implemented` hasta que se escriba su lógica. El contrato completo está en `openapi.yaml`.

## Cómo trabajar con el servicio

| Qué | Dónde |
|---|---|
| Desarrollar y ejecutar en local | README del repositorio, sección "Desarrollar" |
| Verificar (pruebas, seguridad, imagen) | README del repositorio, sección "Verificar" |
| Desplegar y operar | README del repositorio, secciones "Operar" y "Troubleshooting" |
| Integración continua | `.github/workflows/ci.yml`: valida y no publica |
| Despliegue continuo | `.github/workflows/cd.yml`: publica la imagen y actualiza el despliegue solo en `main` |

## Observabilidad

Las alertas y el dashboard de New Relic están en `observability/newrelic/`. El servicio emite su estado en `/health`.
