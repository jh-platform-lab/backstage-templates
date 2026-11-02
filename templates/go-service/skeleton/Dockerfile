# Imagen para Kubernetes (EKS). Para Lambda ver Dockerfile.lambda.
FROM golang:1.24 AS build
WORKDIR /src
COPY go.mod ./
COPY *.go ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server .

# distroless/static: sin shell ni gestor de paquetes. Usuario numerico para que Kubernetes
# pueda verificar runAsNonRoot. Las sondas /health las hace Kubernetes (no hay HEALTHCHECK de Docker).
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/server /server
USER 10001:10001
EXPOSE 8000
ENTRYPOINT ["/server"]
