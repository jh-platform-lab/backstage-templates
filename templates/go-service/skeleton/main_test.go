package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func call(method, path string) *httptest.ResponseRecorder {
	rec := httptest.NewRecorder()
	newMux().ServeHTTP(rec, httptest.NewRequest(method, path, nil))
	return rec
}

func TestHealth(t *testing.T) {
	rec := call(http.MethodGet, "/health")
	if rec.Code != http.StatusOK || !strings.Contains(rec.Body.String(), `"ok"`) {
		t.Fatalf("health: got %d %s", rec.Code, rec.Body.String())
	}
}

// Cada operacion del formulario nace como stub: responde 501 hasta que se implemente.
func TestRoutesNotImplemented(t *testing.T) {
	routes := []struct{ method, path string }{
{%- for api in values.apis %}
		{"${{ api.method }}", "${{ api.path | replace(r/\{[^}]+\}/g, '1') }}"},
{%- endfor %}
	}
	for _, r := range routes {
		if rec := call(r.method, r.path); rec.Code != http.StatusNotImplemented {
			t.Errorf("%s %s: got %d, want 501", r.method, r.path, rec.Code)
		}
	}
}
