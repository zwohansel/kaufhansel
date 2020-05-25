package de.hanselmann.shoppinglist.configuration;

import java.util.Optional;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import graphql.GraphQL;
import io.leangen.graphql.spqr.spring.autoconfigure.DataLoaderRegistryFactory;
import io.leangen.graphql.spqr.spring.autoconfigure.SpqrProperties;
import io.leangen.graphql.spqr.spring.autoconfigure.SpqrWebSocketAutoConfiguration;

@Configuration
@EnableWebSocket
public class ShoppingListWebSocketConfig extends SpqrWebSocketAutoConfiguration {
    private final SpqrProperties config;

    public ShoppingListWebSocketConfig(GraphQL graphQL, SpqrProperties config,
            Optional<DataLoaderRegistryFactory> dataLoaderRegistryFactory) {
        super(graphQL, config, dataLoaderRegistryFactory);
        this.config = config;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        String webSocketEndpoint = config.getWs().getEndpoint();
        String graphQLEndpoint = config.getHttp().getEndpoint();
        String endpointUrl = webSocketEndpoint == null ? graphQLEndpoint : webSocketEndpoint;
        registry.addHandler(webSocketHandler(webSocketExecutor(webSocketContextFactory())), endpointUrl)
                .setAllowedOrigins(config.getWs().getAllowedOrigins()).addInterceptors(
                        new HttpSessionHandshakeInterceptor(), new ShoppingListWebSocketAuthenticationInterceptor());
    }

}
