// Adaptador para AWS Lambda (Function URL). En Kubernetes se usa src/server.js y este archivo no se carga.
const serverless = require('serverless-http');
const app = require('./app');

module.exports.handler = serverless(app);
