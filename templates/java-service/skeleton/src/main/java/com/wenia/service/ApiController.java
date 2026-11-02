package com.wenia.service;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/** /health y una ruta por cada operacion del formulario (stub 501 hasta implementarla). */
@RestController
public class ApiController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }
{% for api in values.apis %}
    @${{ api.method | capitalize }}Mapping("${{ api.path }}")
    public ResponseEntity<Map<String, String>> ${{ api.name | replace('-', '_') }}() {
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).body(Map.of("detail", "Not implemented"));
    }
{% endfor %}}
