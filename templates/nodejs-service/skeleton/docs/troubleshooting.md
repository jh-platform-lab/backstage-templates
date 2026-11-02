# Troubleshooting

Síntoma, causa probable y qué hacer. Ordénalo por lo que se ve primero.

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Una ruta responde `501 Not implemented` | Es el stub generado | Escribe la lógica en el handler en `src/app.js` |
| El CI falla en `secrets` | Gitleaks encontró una credencial | Revócala, bórrala del historial y vuelve a empujar |
| El CI falla en npm audit | Dependencia con vulnerabilidad conocida | sube la versión en `package.json`, regenera `package-lock.json` y prueba de nuevo |
| El CI falla en la imagen (Trivy) | Vulnerabilidad HIGH o CRITICAL con arreglo | Actualiza la imagen base o la dependencia |
| CD: `Could not load credentials` | Falta la variable `AWS_ROLE_ARN` | Es lo esperado antes del primer `terraform apply`; ver *Operación* |
| CD: falla "Deploy Lambda" la primera vez | La función todavía no existe | Haz el paso 4 del primer despliegue |
| La URL de Lambda responde 403 | Faltan los permisos públicos de la URL | Reaplica Terraform |
| El contenedor queda `unhealthy` | `/health` no responde | `docker logs <contenedor>` y revisa el arranque (node) |
| Kind: `ImagePullBackOff` | La imagen `:local` no está cargada | Vuelve a correr `bash scripts/kind-deploy.sh` |
| New Relic no muestra datos | el agente de Node no arranca sin licencia (por diseño) | define `NEW_RELIC_LICENSE_KEY` desde un Secret y reinicia |
