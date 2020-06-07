package de.hanselmann.shoppinglist.service;

import java.util.Arrays;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;

@Component
public class ShoppingListAuthenticationService implements AuthenticationProvider {

    private final ShoppingListUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public ShoppingListAuthenticationService(ShoppingListUserRepository userRepository,
            PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
        this.userRepository = userRepository;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String username = authentication.getName();
        String password = authentication.getCredentials().toString();

        Optional<ShoppingListUser> optionalUser = userRepository.findUserByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new BadCredentialsException("Falsche Logindaten");
        }

        ShoppingListUser user = optionalUser.get();

        if (!user.hasPassword()) {
            setPassword(user, password);
        }

        if (isPasswordCorrect(user, password)) {
            return new UsernamePasswordAuthenticationToken(user.getId(), user.getPassword(),
                    Arrays.asList(new SimpleGrantedAuthority("ROLE_SHOPPER")));
        }

        throw new BadCredentialsException("Falsche Logindaten");
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return authentication.equals(UsernamePasswordAuthenticationToken.class);
    }

    private void setPassword(ShoppingListUser user, String password) {
        if (password.isEmpty()) {
            return;
        }
        user.setPassword(passwordEncoder.encode(password));
        userRepository.save(user);
    }

    private boolean isPasswordCorrect(ShoppingListUser user, String password) {
        if (!user.hasPassword()) {
            return false;
        }
        return passwordEncoder.matches(password, user.getPassword());
    }
}
