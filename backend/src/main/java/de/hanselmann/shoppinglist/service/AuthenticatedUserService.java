package de.hanselmann.shoppinglist.service;

import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.security.AuthenticatedToken;

@Service
public class AuthenticatedUserService {

    public Optional<ShoppingListUser> findCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            return Optional.of(((AuthenticatedToken) auth).getUser());
        }
        return Optional.empty();
    }

}
