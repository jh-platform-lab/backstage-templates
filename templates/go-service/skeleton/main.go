package main

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"os"
)

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}

func notImplemented(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusNotImplemented, map[string]string{"detail": "Not implemented"})
}

// newMux registra /health y una ruta por cada operacion del formulario.
func newMux() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
{% for api in values.apis %}
	mux.HandleFunc("${{ api.method }} ${{ api.path }}", notImplemented)
{%- endfor %}
	return mux
}

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	addr := ":8000"
	logger.Info("listening", "service", "${{ values.name }}", "addr", addr)
	if err := http.ListenAndServe(addr, newMux()); err != nil {
		logger.Error("server stopped", "error", err.Error())
		os.Exit(1)
	}
}
