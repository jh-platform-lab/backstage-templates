# Changelog

## 1.1.0

- Nuevo lenguaje: Node.js 24 (Express). El campo `language` acepta `python` o `nodejs`.
- El skeleton se divide en `skeleton-common` (Terraform, K8S, CD, observabilidad, catálogo, OpenAPI), `skeleton-python` y `skeleton-nodejs`. La plantilla genera en tres pasos y los de lenguaje llevan `if`.
- Tipo `k8s` con manifiestos reales (`k8s/`) y `scripts/kind-deploy.sh` para probarlo en Kind.
- Nota: el agente de New Relic para Node no arranca sin licencia, por eso se activa solo si existe `NEW_RELIC_LICENSE_KEY`.

## 1.0.0

- Plantilla inicial `python-service`: formulario con validación, creación del repo y registro en el catálogo.
