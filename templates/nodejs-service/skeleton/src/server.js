const app = require('./app');

const port = Number(process.env.PORT || 8000);
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`${{ values.name }} listening on ${port}`);
});

// Kubernetes envia SIGTERM al reemplazar el pod: se cierra sin cortar las peticiones en curso.
process.on('SIGTERM', () => server.close(() => process.exit(0)));
