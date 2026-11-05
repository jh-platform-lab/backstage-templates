# Estado final y recreación de las plantillas

Este repo y [`wenia-platform`](https://github.com/jh-platform-lab/wenia-platform) son los únicos que permanecen del caso técnico. Todo lo demás (servicios de demostración, cuenta AWS, contenedores) se puede regenerar a partir de aquí. La guía completa de limpieza y recreación está en `wenia-platform/docs/limpieza-y-recreacion.md`.

## Qué hay aquí

Nueve plantillas en `templates/<nombre>/` (`template.yaml` + `skeleton/`), con sus versiones en el `README.md` y su historial en `CHANGELOG.md`.

## Cómo recrear un servicio de demostración

1. Levantar Backstage (ver la guía de `wenia-platform`, sección 5.3).
2. **Create** → elegir la plantilla (`python-service`, `nodejs-service`, `go-service`, `java-service`, `s3-bucket`, `sqs-queue`) y rellenar el formulario con un nombre nuevo.
3. Con tipo Lambda o Kubernetes, el CD del repo generado necesita la cuenta AWS preparada con `infra/bootstrap` (sección 5.1 de la guía).

## Estado y límites al cierre

| Tema | Estado |
|---|---|
| Go, Python, Node.js, S3, SQS | Verificados de punta a punta, con evidencia en `wenia-platform/evidence/` |
| Java | Genera y despliega; la CI falla en Trivy por CVE-2026-47884 (requiere Spring Boot 7) |
| `update-service` | En 1.3.0: puede degradar servicios con plantillas 1.6.x |
| `add-observability` | Abre un PR vacío si el servicio ya tiene observabilidad |
| Equipos del formulario | Lista duplicada en seis `template.yaml` (`data-team` añadido a mano en #37) |

## Probar una plantilla en local

`yarn start` en `wenia-platform/backstage` lee esta carpeta del disco, así que un cambio se ve al instante. Cuando está en `main`, el contenedor la lee desde GitHub.
