package de.hanselmann.shoppinglist.configuration;

import java.util.Optional;

import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import graphql.GraphQL;
import io.leangen.graphql.spqr.spring.autoconfigure.DataLoaderRegistryFactory;
import io.leangen.graphql.spqr.spring.autoconfigure.SpqrProperties;
import io.leangen.graphql.spqr.spring.autoconfigure.SpqrWebSocketAutoConfiguration;
import io.leangen.graphql.spqr.spring.web.apollo.PerConnectionApolloHandler;

@Configuration
@EnableWebSocket
@ConditionalOnProperty(name = "shoppinglist.ws.enabled", havingValue = "true", matchIfMissing = false)
public class ShoppingListWebSocketConfig extends SpqrWebSocketAutoConfiguration {
    private final SpqrProperties config;

    public ShoppingListWebSocketConfig(GraphQL graphQL, SpqrProperties config,
            Optional<DataLoaderRegistryFactory> dataLoaderRegistryFactory) {
        super(graphQL, config, dataLoaderRegistryFactory);
        this.config = config;

        LoggerFactory.getLogger(getClass()).info("GraphQL websocket subscriptions enabled.");
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {

        String webSocketEndpoint = config.getWs().getEndpoint();
        String graphQLEndpoint = config.getHttp().getEndpoint();
        String endpointUrl = webSocketEndpoint == null ? graphQLEndpoint : webSocketEndpoint;

        PerConnectionApolloHandler apolloHandler = webSocketHandler(webSocketExecutor(webSocketContextFactory()));
        ConcurrentApolloHandlerDecorator threadSafeHandler = new ConcurrentApolloHandlerDecorator(apolloHandler);

        registry.addHandler(threadSafeHandler, endpointUrl)
                .setAllowedOrigins(config.getWs().getAllowedOrigins())
                .addInterceptors(
                        new HttpSessionHandshakeInterceptor(),
                        new ShoppingListWebSocketAuthenticationInterceptor());
    }

}
