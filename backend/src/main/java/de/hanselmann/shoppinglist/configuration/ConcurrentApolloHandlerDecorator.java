package de.hanselmann.shoppinglist.configuration;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.SubProtocolCapable;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.WebSocketMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.ConcurrentWebSocketSessionDecorator;

import io.leangen.graphql.spqr.spring.web.apollo.PerConnectionApolloHandler;

public class ConcurrentApolloHandlerDecorator implements WebSocketHandler, SubProtocolCapable {

    private static final int SEND_TIME_LIMIT = 10 * 1000;

    private static final int SEND_BUFFERSIZE_LIMIT = 512 * 1024;

    private final PerConnectionApolloHandler apolloHandler;
    private final Map<String, ConcurrentWebSocketSessionDecorator> sessions = new ConcurrentHashMap<>();

    public ConcurrentApolloHandlerDecorator(PerConnectionApolloHandler apolloHandler) {
        this.apolloHandler = apolloHandler;
    }

    @Override
    public List<String> getSubProtocols() {
        return apolloHandler.getSubProtocols();
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        ConcurrentWebSocketSessionDecorator threadSafeSession = new ConcurrentWebSocketSessionDecorator(session,
                SEND_TIME_LIMIT, SEND_BUFFERSIZE_LIMIT);
        sessions.put(session.getId(), threadSafeSession);
        apolloHandler.afterConnectionEstablished(threadSafeSession);
    }

    @Override
    public void handleMessage(WebSocketSession session, WebSocketMessage<?> message) throws Exception {
        apolloHandler.handleMessage(getThreadSafeSession(session), message);
    }

    private ConcurrentWebSocketSessionDecorator getThreadSafeSession(WebSocketSession session) {
        ConcurrentWebSocketSessionDecorator threadSafeSession = sessions.get(session.getId());

        if (threadSafeSession == null) {
            throw new IllegalStateException("Session with id " + session.getId() + " is unknown.");
        }

        return threadSafeSession;
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        apolloHandler.handleTransportError(getThreadSafeSession(session), exception);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus closeStatus) throws Exception {
        apolloHandler.afterConnectionClosed(getThreadSafeSession(session), closeStatus);
        sessions.remove(session.getId());
    }

    @Override
    public boolean supportsPartialMessages() {
        return apolloHandler.supportsPartialMessages();
    }

}
