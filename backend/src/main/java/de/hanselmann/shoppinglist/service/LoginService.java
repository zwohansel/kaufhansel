package de.hanselmann.shoppinglist.service;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.configuration.ShoppingListProperties;
import de.hanselmann.shoppinglist.model.GraphQlResponse;
import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLMutation;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
public class LoginService {
    private final static Logger LOGGER = LoggerFactory.getLogger(LoginService.class);

    private final static int TIMEOUT_SECONDS = 60 * 60 * 8;

    private final HttpServletRequest request;
    private final HttpServletResponse response;
    private final ShoppingListProperties properties;
    private final ShoppingListAuthenticationService authenticationService;

    @Autowired
    public LoginService(HttpServletRequest request, HttpServletResponse response,
            ShoppingListProperties properties, ShoppingListAuthenticationService authenticationService) {
        this.request = request;
        this.response = response;
        this.properties = properties;
        this.authenticationService = authenticationService;
    }

    @GraphQLMutation
    public @GraphQLNonNull GraphQlResponse<String> login(
            @GraphQLNonNull @GraphQLArgument(name = "username") String username,
            @GraphQLNonNull @GraphQLArgument(name = "password") String password) {

        try {
            var unauthenticatedUser = new UsernamePasswordAuthenticationToken(username, password);
            Authentication authenticatedUser = authenticationService.authenticate(unauthenticatedUser);
            return loginUser(authenticatedUser);
        } catch (AuthenticationException e) {
            return GraphQlResponse.fail("Falsche Logindaten");
        }
    }

    private GraphQlResponse<String> loginUser(Authentication auth) {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        securityContext.setAuthentication(auth);
        HttpSession session = request.getSession();
        session.setAttribute("SPRING_SECURITY_CONTEXT", securityContext);
        session.setMaxInactiveInterval(TIMEOUT_SECONDS);

        Cookie authCookie = new Cookie("SHOPPER_LOGGED_IN", auth.getName());
        authCookie.setMaxAge(TIMEOUT_SECONDS);

        LOGGER.info("Cookie secure: {}", properties.isSecureCookie());
        authCookie.setSecure(properties.isSecureCookie());

        response.addCookie(authCookie);

        return GraphQlResponse.success(auth.getName());
    }

}
