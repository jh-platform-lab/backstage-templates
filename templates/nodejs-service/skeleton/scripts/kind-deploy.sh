#!/usr/bin/env bash
# Despliega el servicio en un cluster Kind local (simula EKS) y lo prueba con curl.
# Requiere docker, kind y kubectl. No toca ningun otro cluster: todos los comandos de
# kubectl usan --context explicito (kind-${CLUSTER}), nunca el contexto activo.
#
# Uso:  bash scripts/kind-deploy.sh               construye la imagen local y despliega
#       bash scripts/kind-deploy.sh --ecr [tag]   baja de ECR la imagen que publico el CD y despliega
#                                                 (tag por defecto: el commit actual; requiere aws login)
#       bash scripts/kind-deploy.sh --delete      borra el cluster local
set -euo pipefail

NAME="${{ values.name }}"
CLUSTER="${KIND_CLUSTER:-wenia-eks}"
CTX="kind-${CLUSTER}"
PORT="${LOCAL_PORT:-8080}"
REGION="${AWS_REGION:-us-east-1}"
cd "$(dirname "${BASH_SOURCE[0]}")/.."

MODE="build"
TAG=""
case "${1:-}" in
  --delete)
    kind delete cluster --name "$CLUSTER"
    exit 0
    ;;
  --ecr)
    MODE="ecr"
    TAG="${2:-$(git rev-parse HEAD)}"
    ;;
  "") ;;
  *)
    echo "Uso: bash scripts/kind-deploy.sh [--ecr [tag] | --delete]" >&2
    exit 2
    ;;
esac

if ! kind get clusters | grep -qx "$CLUSTER"; then
  kind create cluster --name "$CLUSTER"
fi

if [ "$MODE" = "ecr" ]; then
  # Igual que haria EKS: la imagen sale de ECR, la que publico el CD con el SHA del commit.
  ACCOUNT="$(aws sts get-caller-identity --query Account --output text)"
  REGISTRY="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com"
  aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"
  # El CD construye en linux/amd64; en un Mac con Apple Silicon corre emulado.
  docker pull --platform linux/amd64 "${REGISTRY}/${NAME}:${TAG}"
  # El manifiesto usa la etiqueta :local; se reetiqueta para no editar k8s/.
  docker tag "${REGISTRY}/${NAME}:${TAG}" "${NAME}:local"
else
  docker build -t "${NAME}:local" .
fi
kind load docker-image "${NAME}:local" --name "$CLUSTER"

kubectl --context "$CTX" apply -f k8s/
# Fuerza el reinicio para tomar la imagen recien cargada (misma etiqueta :local).
kubectl --context "$CTX" rollout restart deployment/"$NAME"
kubectl --context "$CTX" rollout status deployment/"$NAME" --timeout=120s

kubectl --context "$CTX" port-forward service/"$NAME" "${PORT}:80" >/dev/null 2>&1 &
pf=$!
trap 'kill $pf 2>/dev/null || true' EXIT
sleep 3

echo "--- GET /health"
curl -fsS "http://127.0.0.1:${PORT}/health"
echo
echo "--- OK: ${NAME} responde dentro de Kind (contexto ${CTX}, imagen ${MODE})"
