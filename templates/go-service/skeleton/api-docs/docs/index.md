# APIs

El contrato completo está en `openapi.yaml`, en la raíz del repositorio. Backstage lo registra como la API `${{ values.name }}-api` en el catálogo.

!!! info "Base URL"
    En **Lambda** la URL es la Function URL del despliegue. En **Kubernetes** es el Service dentro del cluster; en local, el port-forward de `scripts/kind-deploy.sh`.

    ```bash
    export BASE_URL=http://localhost:8080
    ```

## Resumen

| Método | Ruta | Operación | Estado |
|---|---|---|---|
| GET | `/health` | `health` | ✅ Implementada |
{%- for api in values.apis %}
| ${{ api.method }} | `${{ api.path }}` | `${{ api.name }}` | 🧩 501 hasta implementar |
{%- endfor %}

## Detalle por operación

{%- for api in values.apis %}

### ${{ api.method }} `${{ api.path }}` · ${{ api.name }}

!!! warning "Estado: stub"
    Responde `501 Not implemented` hasta que se escriba su lógica. El contrato de entrada y salida se define en `openapi.yaml`.

```bash
curl -i -X ${{ api.method }} "$BASE_URL${{ api.path | replace('{id}', '1') }}"
```

Respuesta de hoy: `501` con `{"detail": "Not implemented"}`.
{%- endfor %}

## Salud

```bash
curl -i "$BASE_URL/health"
```

Respuesta: `200` con `{"status": "ok"}`.
