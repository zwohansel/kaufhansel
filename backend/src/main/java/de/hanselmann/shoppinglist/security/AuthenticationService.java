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
                .map(user -> new AuthenticatedToken(token, user))
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UnAuthenticatedToken.class);
    }
}
