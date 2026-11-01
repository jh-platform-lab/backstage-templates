'use strict';
// Configuracion del agente APM. La licencia llega por NEW_RELIC_LICENSE_KEY (Secret en Kubernetes).
// El agente de Node se niega a arrancar sin licencia (detiene la app), a diferencia del de Python:
// por eso solo se activa si NEW_RELIC_LICENSE_KEY existe. Sin ella el servicio arranca igual.
exports.config = {
  agent_enabled: Boolean(process.env.NEW_RELIC_LICENSE_KEY),
  app_name: [process.env.NEW_RELIC_APP_NAME || '${{ values.name }}'],
  distributed_tracing: { enabled: true },
  application_logging: {
    enabled: true,
    forwarding: { enabled: true },
    metrics: { enabled: true },
  },
  logging: { level: 'info', filepath: 'stdout' },
};
