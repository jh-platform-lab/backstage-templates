# ${{ values.name }}

${{ values.description }}

Generado por la plantilla **Infra: bucket S3** (versión `${{ values.templateVersion }}`). Propietario: `${{ values.owner }}`.

## Qué crea

Un bucket S3 privado con cifrado KMS (llave propia con rotación), versionado, bloqueo total de acceso público, TLS obligatorio y expiración de versiones antiguas.

## Estructura

| Ruta | Para qué sirve |
|---|---|
| `terraform/` | Recurso y sus variables (`terraform.tfvars` ya trae los valores del formulario) |
| `.github/workflows/ci.yml` | `fmt`, `validate` y `checkov` en cada PR; no toca la nube |
| `.github/workflows/cd.yml` | `terraform apply` al fusionar en `main`, con aprobación del entorno `production` y OIDC |

## Variables

| Variable | Qué controla |
|---|---|
| `name` | Prefijo del bucket; el nombre final es `<name>-<id de cuenta>` para ser único |
| `noncurrent_days` | Días que se conservan las versiones antiguas de los objetos |
| `force_destroy` | Si `true`, `destroy` borra el bucket aunque tenga objetos (déjalo en `false`) |

## Desarrollar y verificar

```bash
cd terraform
docker run --rm -v "$PWD:/w" -w /w hashicorp/terraform:1.12 fmt -check -diff
docker run --rm -v "$PWD:/w" -w /w hashicorp/terraform:1.12 init -backend=false
docker run --rm -v "$PWD:/w" -w /w hashicorp/terraform:1.12 validate
docker run --rm -v "$PWD:/tf" bridgecrew/checkov:3.4.0 -d /tf --framework terraform --compact
```

## Operar

El CD necesita, en el repositorio: la variable `AWS_ROLE_ARN` (rol OIDC con permisos sobre este recurso), la variable `TF_STATE_BUCKET` (bucket del estado) y el entorno `production` con aprobación. El estado vive en `s3://<bucket>/${{ values.name }}/terraform.tfstate` con bloqueo por archivo.

Para cambiar el recurso: edita `terraform/terraform.tfvars` o los `.tf`, abre un PR, revisa el CI y fusiona; el CD aplica tras la aprobación.

## Troubleshooting

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| `terraform apply`: `BucketAlreadyExists` | El nombre ya existe en la región | Cambia `name` en `terraform.tfvars` |
| `destroy`: `BucketNotEmpty` | El bucket tiene objetos o versiones | Vacíalo o usa `force_destroy = true` de forma consciente |
| CD: `AccessDenied` al asumir el rol | Falta `AWS_ROLE_ARN` o la confianza OIDC no incluye `repo:jh-platform-lab/${{ values.name }}:environment:production` | Revisa la variable y la política de confianza del rol |
| CD: `Error acquiring the state lock` | Otra ejecución en curso o bloqueo huérfano | Espera; si quedó huérfano, borra el `.tflock` del estado tras confirmar que nadie aplica |
| CI: falla `terraform fmt` | Archivo sin formatear | Ejecuta `terraform fmt` y sube el cambio |
