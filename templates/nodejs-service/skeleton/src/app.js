const express = require('express');

const app = express();
app.disable('x-powered-by');
app.use(express.json());

app.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});
{% for api in values.apis %}
app.${{ api.method | lower }}('${{ api.path | replace(r/\{([^}]+)\}/g, ':$1') }}', (_req, res) => {
  res.status(501).json({ detail: 'Not implemented' });
});
{% endfor %}
module.exports = app;
