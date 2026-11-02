# Arquitectura

Cómo corre el servicio y cómo llega a producción.

## Ejecución

```mermaid
flowchart LR
  C[Cliente] -->|HTTPS| T{Tipo de servicio}
  T -->|lambda| FU[Function URL] --> L[Lambda<br/>imagen de ECR]
  T -->|k8s| S[Service] --> P[Pods EKS<br/>2 réplicas]
  L --> O[(CloudWatch)]
  P --> NR[(New Relic APM)]
  classDef store fill:#eef,stroke:#669;
```

La imagen se construye una vez y se usa en los dos tipos de despliegue. El tipo lo decide el campo `serviceType` del formulario (`${{ values.serviceType }}` en este servicio).

## Entrega

```mermaid
flowchart LR
  D[Desarrollador] -->|pull request| CI[CI<br/>pruebas · seguridad · Terraform · imagen]
  CI -->|merge a main| CD[CD<br/>entorno production · OIDC]
  CD -->|push| E[(ECR)]
  E -->|lambda| L[update-function-code]
  E -->|k8s| K[Despliegue en EKS<br/>marcador pendiente]
```

!!! note "Estado del despliegue a Kubernetes"
    El CD publica la imagen en ECR. El paso de despliegue en EKS es un marcador hasta que exista el cluster.

## Componentes

| Componente | Archivo | Función |
|---|---|---|
| Aplicación | `src/main/java/com/wenia/service/ApiController.java` | Rutas y lógica del servicio |
| Contrato | `openapi.yaml` | Documento de la API, registrado en el catálogo |
| Imagen K8S | `Dockerfile` | Usuario sin privilegios, sin shell de administración |
| Imagen Lambda | `Dockerfile.lambda` | AWS Lambda Web Adapter |
| Infraestructura | `terraform/` | ECR, rol OIDC de CD y función Lambda (si hay `image_uri`) |
| Kubernetes | `k8s/` | Deployment de 2 réplicas, probes y Service |
| Observabilidad | `observability/newrelic/` | Alertas y dashboard como Terraform |
| Catálogo | `catalog-info.yaml` | Component y API en Backstage |
