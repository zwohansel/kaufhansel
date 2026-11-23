package de.hanselmann.shoppinglist.security;

import java.io.IOException;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

public class AuthenticationTokenFilter extends OncePerRequestFilter {
    private static final String AUTHORIZATION_HEADER_NAME = "AUTHORIZATION";
    private static final String AUTHORIZATION_HEADER_VALUE_PREFIX = "Bearer ";

    private final AuthenticationManager authenticationManager;

    public AuthenticationTokenFilter(AuthenticationManager authenticationManager) {
        this.authenticationManager = authenticationManager;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader(AUTHORIZATION_HEADER_NAME);
        if (authorizationHeader != null && authorizationHeader.startsWith(AUTHORIZATION_HEADER_VALUE_PREFIX)) {
            String authToken = authorizationHeader.substring(AUTHORIZATION_HEADER_VALUE_PREFIX.length());
            // The authorization filter does not turn an unauthenticated token into an
            // authenticated one, so we have to consult the authentication manager here.
            try {
                Authentication authentication = authenticationManager.authenticate(new UnAuthenticatedToken(authToken));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            } catch (AuthenticationException e) {
                SecurityContextHolder.clearContext();
            }
        }
        filterChain.doFilter(request, response);
    }
}
