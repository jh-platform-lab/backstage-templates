# ${{ values.name }}

${{ values.description }}

| | |
|---|---|
| Equipo propietario | `${{ values.owner }}` |
| Tipo de servicio | `${{ values.serviceType }}` |
| Lenguaje | Go 1.24 (net/http) |
| Versión de la plantilla | `${{ values.templateVersion }}` (anotación `wenia.io/template-version` del catálogo) |

## Qué se creó

| Archivo o carpeta | Para qué sirve |
|---|---|
| `main.go` | Servicio net/http: `/health` y una ruta por cada operación del formulario |
| `openapi.yaml`, `catalog-info.yaml` | Contrato de la API y registro en el catálogo de Backstage (Component y API) |
| `Dockerfile` | Imagen para Kubernetes: multi-stage, usuario sin privilegios (uid 10001) |
| `Dockerfile.lambda` | Imagen para AWS Lambda (AWS Lambda Web Adapter) |
| `main_test.go` | Pruebas con `go test` |
| `.github/workflows/ci.yml` | **CI**: valida, no publica nada |
| `.github/workflows/cd.yml` | **CD**: publica la imagen y despliega (solo en `main`) |
| `k8s/` | Deployment (2 réplicas, probes, `securityContext` restrictivo) y Service para el tipo Kubernetes |
| `scripts/kind-deploy.sh` | Despliega `k8s/` en un cluster Kind local y lo prueba con curl |
| `terraform/` | ECR, rol OIDC de CD y, para Lambda, la función con su URL pública |
| `observability/newrelic/` | Alertas y dashboard de New Relic como código |

Rutas generadas (devuelven `501 Not implemented` hasta que escribas su lógica):

| Método | Ruta | Operación |
|---|---|---|
| GET | `/health` | `health` (ya implementada) |
{%- for api in values.apis %}
| ${{ api.method }} | `${{ api.path }}` | `${{ api.name }}` |
{%- endfor %}

## Desarrollar

```bash
go run .                               # http://127.0.0.1:8000/health
```


Para implementar una ruta, edita su handler en `main.go`, actualiza `openapi.yaml` si cambia el contrato y agrega su prueba en `main_test.go`.

## Verificar

| Qué | Comando |
|---|---|
| Pruebas | `go test ./...` |
| Seguridad del código | `go vet ./...` |
| Dependencias vulnerables | `go run golang.org/x/vuln/cmd/govulncheck@v1.1.4 ./...` |
| Secretos en el repo | `docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:v8.21.2 detect --source /repo --no-banner` |
| Imagen (K8S) | `docker build -f Dockerfile -t ${{ values.name }} . && docker run --rm -p 8000:8000 ${{ values.name }}` |
| Imagen (Lambda) | `docker build -f Dockerfile.lambda -t ${{ values.name }}-lambda .` |
| Kubernetes (local) | `bash scripts/kind-deploy.sh` crea el cluster Kind `local-dev`, despliega y hace `curl /health`; `--delete` lo borra |
| Terraform | en `terraform/`: `terraform fmt -check`, `terraform init -backend=false`, `terraform validate` |

El CI ejecuta lo mismo en cada PR: `test`, `terraform`, `secrets` e `image` (con escaneo Trivy de HIGH y CRITICAL).

## Operar

### Primer despliegue (una sola vez)

1. En `terraform/`: `terraform init && terraform apply`. Crea el repositorio ECR y el rol de CD. **La Lambda aún no existe** (no hay imagen todavía).
2. En GitHub, **Settings → Secrets and variables → Actions → Variables**: crea `AWS_ROLE_ARN` con el valor de `terraform output cd_role_arn`.
3. Haz push a `main`. El CD construye y publica la imagen. En Lambda, el último paso falla porque la función no existe: es lo esperado.
4. `terraform apply -var image_uri=<url ECR>:<sha del commit>` crea la función y su URL pública (`terraform output function_url`).

Desde entonces cada push a `main` publica una imagen etiquetada con el SHA y, en Lambda, actualiza el código de la función. Terraform ignora la imagen (`ignore_changes`) para no revertir lo que despliega el CD.

### Según el tipo de servicio

| Tipo | Qué hace el CD hoy |
|---|---|
| `lambda` | Publica la imagen en ECR y ejecuta `update-function-code` |
| `k8s` | Publica la imagen en ECR. En local, `scripts/kind-deploy.sh` despliega `k8s/` en Kind. El paso de despliegue a EKS del CD sigue siendo un marcador hasta que exista el cluster |

### Observabilidad

| Dónde | Qué ver |
|---|---|
| Logs | Kubernetes: `kubectl logs`. Lambda: grupo de CloudWatch `/aws/lambda/${{ values.name }}` |
| Salud | `GET /health` |
| New Relic (APM) | Esta versión de la plantilla **no incluye el agente APM de Go**: las alertas de `observability/newrelic/` solo reciben datos cuando lo añadas al servicio. Mientras tanto usa logs y `/health` |
| Alertas y dashboard | En `observability/newrelic/`: `export TF_VAR_api_key=NRAK-...` y `terraform apply -var account_id=<id>` |

New Relic para Lambda requiere la extensión de New Relic, que no se incluye en la imagen: hoy ese tipo se observa con CloudWatch.

## Troubleshooting

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Una ruta responde `501 Not implemented` | Es el stub generado | Escribe la lógica en `main.go` |
| CI: falla `secrets` | Gitleaks encontró un secreto | Revoca la credencial, elimínala del historial y vuelve a empujar. No basta con borrar el archivo |
| CI: falla `govulncheck` | Dependencia con vulnerabilidad conocida | Sube la versión en `go.mod` (`go get -u` y `go mod tidy`) y prueba de nuevo |
| CI: `image` falla en "Set up job" | Etiqueta de una acción de GitHub inexistente | Revisa la versión del `uses:` en el workflow |
| CI: `image` falla en Trivy | Vulnerabilidad HIGH o CRITICAL con arreglo disponible | Actualiza la imagen base o la dependencia |
| CD: `Could not assume role` | Falta `AWS_ROLE_ARN`, o el rol no confía en este repo y entorno | Revisa la variable y que el entorno sea `production`; el rol solo acepta `repo:<org>/${{ values.name }}:environment:production` |
| CD: falla "Deploy Lambda" la primera vez | La función aún no existe | Haz el paso 4 del primer despliegue |
| Terraform no crea la Lambda | `image_uri` vacío a propósito | Pasa `-var image_uri=<url ECR>:<sha>` |
| La URL de la Lambda responde 403 | Faltan los dos permisos públicos de la URL | Reaplica Terraform: `FunctionURLAllowPublicAccess` y `FunctionURLAllowInvokeAction` |
| Kind: el pod queda en `ImagePullBackOff` | La imagen `${{ values.name }}:local` no está cargada en el cluster | Vuelve a correr `bash scripts/kind-deploy.sh` (construye y la carga con `kind load`) |
| El contenedor queda `unhealthy` | `/health` no responde | `docker logs <contenedor>` y revisa el arranque del servidor (el binario Go) |
| New Relic no muestra datos | El servicio no incluye el agente APM | Añade el agente de Go al servicio y define `NEW_RELIC_LICENSE_KEY` |

## Evolución de la plantilla

Este servicio se creó con la versión `${{ values.templateVersion }}` de la plantilla `go-service`. La anotación `wenia.io/template-version` en `catalog-info.yaml` permite saber qué servicios están desactualizados cuando la plantilla cambie.
