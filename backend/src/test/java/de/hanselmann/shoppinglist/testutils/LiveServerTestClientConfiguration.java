package de.hanselmann.shoppinglist.testutils;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Lazy;
import org.springframework.test.web.servlet.client.RestTestClient;

/**
 * Spring Boot does not auto-configure a test client that is bound to the
 * running web server, so we provide one ourselves.
 */
@TestConfiguration
public class LiveServerTestClientConfiguration {

    // Lazy because local.server.port is only known once the web server has been
    // started, which happens after the singleton beans have been created.
    @Bean
    @Lazy
    public RestTestClient restTestClient(@Value("${local.server.port}") int port) {
        return RestTestClient.bindToServer().baseUrl("http://localhost:" + port).build();
    }
}
