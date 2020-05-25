package de.hanselmann.shoppinglist.configuration;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;

public class ShoppingListWebSocketAuthenticationInterceptor implements HandshakeInterceptor {
    private final static Logger LOGGER = LoggerFactory.getLogger(ShoppingListWebSocketAuthenticationInterceptor.class);

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
            Map<String, Object> attributes) throws Exception {

        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication authentication = securityContext.getAuthentication();
        boolean authenticated = authentication.getAuthorities().stream()
                .anyMatch(a -> "ROLE_SHOPPER".equals(a.getAuthority()));

        LOGGER.info("Web socket connection from {} authenticated: {}", request.getRemoteAddress(), authenticated);

        return authenticated;
    }

    @Override
    public void afterHandshake(ServerHttpRequest request, ServerHttpResponse response, WebSocketHandler wsHandler,
            Exception exception) {

    }

}
