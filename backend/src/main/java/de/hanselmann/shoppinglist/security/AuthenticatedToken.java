package de.hanselmann.shoppinglist.security;

import java.util.Collection;
import java.util.Collections;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

@SuppressWarnings("serial")
public class AuthenticatedToken implements Authentication {
    private final String token;
    private final ShoppingListUser user;

    public AuthenticatedToken(String token, ShoppingListUser user) {
        this.token = token;
        this.user = user;
    }

    public ShoppingListUser getUser() {
        return user;
    }

    @Override
    public String getName() {
        return String.valueOf(user.getId());
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(new SimpleGrantedAuthority("ROLE_SHOPPER"));
    }

    @Override
    public Object getCredentials() {
        return token;
    }

    @Override
    public Object getDetails() {
        return null;
    }

    @Override
    public Object getPrincipal() {
        return getName();
    }

    @Override
    public boolean isAuthenticated() {
        return true;
    }

    @Override
    public void setAuthenticated(boolean isAuthenticated) throws IllegalArgumentException {
        throw new UnsupportedOperationException();
    }

}
