# Imagen para Kubernetes (EKS). Para Lambda ver Dockerfile.lambda.
FROM node:24-slim

ENV NODE_ENV=production

WORKDIR /srv

# Las dependencias van antes que el codigo para reutilizar la capa en cada build.
COPY package.json package-lock.json ./
# npm y npx no hacen falta al ejecutar: se quitan junto con sus dependencias empaquetadas, que
# suelen traer CVE de la imagen base (undici, brace-expansion) y agrandan la superficie de ataque.
RUN npm ci --omit=dev && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

COPY src ./src
COPY newrelic.js ./

# Usuario sin privilegios con uid numerico para que Kubernetes pueda verificar runAsNonRoot.
USER 10001:10001

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD node -e "fetch('http://127.0.0.1:8000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

# Forma exec: node queda como PID 1 y recibe SIGTERM directo.
# "-r newrelic" carga el agente antes que la app; sin NEW_RELIC_LICENSE_KEY se desactiva y arranca igual.
CMD ["node", "-r", "newrelic", "src/server.js"]
