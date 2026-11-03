# Arquitectura

Cómo corre el servicio y cómo llega a producción.

## Ejecución

{% if values.serviceType == 'lambda' %}
![Ejecución en Lambda](img/runtime-lambda.svg)
{% else %}
![Ejecución en Kubernetes](img/runtime-k8s.svg)
{% endif %}

La imagen se construye una vez y se usa en los dos tipos de despliegue. El tipo lo decide el campo `serviceType` del formulario (`${{ values.serviceType }}` en este servicio).

## Entrega

{% if values.serviceType == 'lambda' %}
![Entrega en Lambda](img/delivery-lambda.svg)
{% else %}
![Entrega en Kubernetes](img/delivery-k8s.svg)
{% endif %}

!!! note "Estado del despliegue a Kubernetes"
    El CD publica la imagen en ECR. Sin cluster EKS, el despliegue se simula en Kind con `scripts/kind-deploy.sh --ecr`, que baja esa misma imagen de ECR.

## Componentes

| Componente | Archivo | Función |
|---|---|---|
| Aplicación | `src/app.js` | Rutas y lógica del servicio |
| Contrato | `openapi.yaml` | Documento de la API, registrado en el catálogo |
| Imagen K8S | `Dockerfile` | Usuario sin privilegios, sin shell de administración |
| Imagen Lambda | `Dockerfile.lambda` | Adaptador serverless-http |
| Infraestructura | `terraform/` | ECR, rol OIDC de CD y función Lambda (si hay `image_uri`) |
| Kubernetes | `k8s/` | Deployment de 2 réplicas, probes y Service |
| Observabilidad | `observability/newrelic/` | Alertas y dashboard como Terraform |
| Catálogo | `catalog-info.yaml` | Component y API en Backstage |
