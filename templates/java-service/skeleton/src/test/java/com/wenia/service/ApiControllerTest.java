package com.wenia.service;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.request;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpMethod;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class ApiControllerTest {

    @Autowired
    MockMvc mvc;

    @Test
    void healthIsOk() throws Exception {
        mvc.perform(request(HttpMethod.GET, "/health"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.status").value("ok"));
    }
{% for api in values.apis %}
    @Test
    void ${{ api.name | replace('-', '_') }}IsNotImplemented() throws Exception {
        mvc.perform(request(HttpMethod.${{ api.method }}, "${{ api.path | replace(r/\{[^}]+\}/g, '1') }}"))
            .andExpect(status().isNotImplemented());
    }
{% endfor %}}
