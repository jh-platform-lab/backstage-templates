# Desarrollo y verificación

## Ejecutar en local

```bash
npm ci
npm run dev                            # http://127.0.0.1:8000/health
```

## Verificar antes de abrir un pull request

| Qué | Comando |
|---|---|
| Pruebas | `npm test` |
| Dependencias | `npm audit --omit=dev --audit-level=high` |
| Imagen Kubernetes | `docker build -f Dockerfile -t ${{ values.name }} .` |
| Imagen Lambda | `docker build -f Dockerfile.lambda -t ${{ values.name }}-lambda .` |
| Kubernetes en local | `bash scripts/kind-deploy.sh` (cluster Kind, prueba con `curl`) |
| Secretos en el repo | `docker run --rm -v "$PWD:/repo" zricethezav/gitleaks:v8.21.2 detect --source /repo --no-banner` |

## Cómo implementar una ruta

1. Escribe la lógica en el handler en `src/app.js`.
2. Actualiza `openapi.yaml` si cambia el contrato.
3. Agrega su prueba en `test/`.
4. Abre un pull request: el CI ejecuta las mismas comprobaciones.
