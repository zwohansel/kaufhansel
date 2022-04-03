package de.hanselmann.shoppinglist.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationCredentialsNotFoundException;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Component;

@Component
public class AuthenticationService implements AuthenticationProvider {
    private final TokenService tokenService;

    @Autowired
    public AuthenticationService(TokenService tokenService) {
        this.tokenService = tokenService;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        if (authentication.getCredentials() == null) {
            throw new AuthenticationCredentialsNotFoundException("Token required");
        }
        final String token = authentication.getCredentials().toString();
        return tokenService.getUserFromTokenIfValid(token)
                // Do not store the user object in AuthenticatedToken!
                // The current hibernate session is closed when this method returns (or maybe a bit later).
                // The actual request handler will get a new hibernate session.
                // When we try to access any lazy-loaded properties of the user object
                // like shoppingLists we will get the exception
                // "LazyInitializationException: could not initialize proxy - no Session".
                // This is because the proxy objects that are attached to the user object
                // are associated with the already closed hibernate session.
                .map(user -> new AuthenticatedToken(token, user.getId()))
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UnAuthenticatedToken.class);
    }
}
