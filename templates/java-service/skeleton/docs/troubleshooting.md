# Troubleshooting

Síntoma, causa probable y qué hacer. Ordénalo por lo que se ve primero.

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Una ruta responde `501 Not implemented` | Es el stub generado | Escribe la lógica en el método en `ApiController.java` |
| El CI falla en `secrets` | Gitleaks encontró una credencial | Revócala, bórrala del historial y vuelve a empujar |
| El CI falla en Trivy (pom.xml) | Dependencia con vulnerabilidad conocida | sube la versión de Spring Boot o de la dependencia en `pom.xml` |
| El CI falla en la imagen (Trivy) | Vulnerabilidad HIGH o CRITICAL con arreglo | Actualiza la imagen base o la dependencia |
| CD: `Could not load credentials` | Falta la variable `AWS_ROLE_ARN` | Es lo esperado antes del primer `terraform apply`; ver *Operación* |
| CD: falla "Deploy Lambda" la primera vez | La función todavía no existe | Haz el paso 4 del primer despliegue |
| La URL de Lambda responde 403 | Faltan los permisos públicos de la URL | Reaplica Terraform |
| El contenedor queda `unhealthy` | `/health` no responde | `docker logs <contenedor>` y revisa el arranque (Spring Boot) |
| Kind: `ImagePullBackOff` | La imagen `:local` no está cargada | Vuelve a correr `bash scripts/kind-deploy.sh` |
| New Relic no muestra datos | el servicio Java no incluye el agente APM de New Relic | añade el agente de Java al servicio; mientras tanto usa logs y `/health` |
