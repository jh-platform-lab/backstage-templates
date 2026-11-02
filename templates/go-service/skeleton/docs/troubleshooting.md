# Troubleshooting

Síntoma, causa probable y qué hacer. Ordénalo por lo que se ve primero.

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Una ruta responde `501 Not implemented` | Es el stub generado | Escribe la lógica en la función correspondiente en `main.go` |
| El CI falla en `secrets` | Gitleaks encontró una credencial | Revócala, bórrala del historial y vuelve a empujar |
| El CI falla en govulncheck | Dependencia con vulnerabilidad conocida | actualiza la versión de Go en `go.mod` y en los Dockerfile |
| El CI falla en la imagen (Trivy) | Vulnerabilidad HIGH o CRITICAL con arreglo | Actualiza la imagen base o la dependencia |
| CD: `Could not load credentials` | Falta la variable `AWS_ROLE_ARN` | Es lo esperado antes del primer `terraform apply`; ver *Operación* |
| CD: falla "Deploy Lambda" la primera vez | La función todavía no existe | Haz el paso 4 del primer despliegue |
| La URL de Lambda responde 403 | Faltan los permisos públicos de la URL | Reaplica Terraform |
| El contenedor queda `unhealthy` | `/health` no responde | `docker logs <contenedor>` y revisa el arranque (el binario Go) |
| Kind: `ImagePullBackOff` | La imagen `:local` no está cargada | Vuelve a correr `bash scripts/kind-deploy.sh` |
| New Relic no muestra datos | el servicio Go no incluye el agente APM de New Relic | añade el agente de Go al servicio; mientras tanto usa logs y `/health` |
