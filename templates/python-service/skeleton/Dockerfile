# Imagen para Kubernetes (EKS). Para Lambda ver Dockerfile.lambda.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /srv

# Las dependencias van antes que el codigo para reutilizar la capa en cada build.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Usuario sin privilegios (uid fijo para que Kubernetes pueda verificar runAsNonRoot).
RUN useradd --system --uid 10001 appuser
USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health')" || exit 1

# Forma exec: uvicorn es PID 1 y recibe SIGTERM directo.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
