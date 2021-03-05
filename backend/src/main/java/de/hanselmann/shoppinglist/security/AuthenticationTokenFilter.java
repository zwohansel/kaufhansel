package de.hanselmann.shoppinglist.security;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

public class AuthenticationTokenFilter extends OncePerRequestFilter {
    private static final String AUTHORIZATION_HEADER_NAME = "AUTHORIZATION";
    private static final String AUTHORIZATION_HEADER_VALUE_PREFIX = "Bearer ";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader(AUTHORIZATION_HEADER_NAME);
        if (authorizationHeader != null && authorizationHeader.startsWith(AUTHORIZATION_HEADER_VALUE_PREFIX)) {
            String authToken = authorizationHeader.substring(AUTHORIZATION_HEADER_VALUE_PREFIX.length());
            UnAuthenticatedToken authentication = new UnAuthenticatedToken(authToken);
            SecurityContextHolder.getContext().setAuthentication(authentication);

        }
        filterChain.doFilter(request, response);
    }
}
