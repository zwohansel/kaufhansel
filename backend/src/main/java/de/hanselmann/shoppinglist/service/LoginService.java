package de.hanselmann.shoppinglist.service;

import java.util.Arrays;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.GraphQlResponse;
import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLMutation;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
public class LoginService {

    private final HttpServletRequest request;
    private final HttpServletResponse response;

    @Autowired
    public LoginService(HttpServletRequest request, HttpServletResponse response) {
        this.request = request;
        this.response = response;
    }

    @GraphQLMutation
    public @GraphQLNonNull GraphQlResponse<Void> login(
            @GraphQLNonNull @GraphQLArgument(name = "username") String username,
            @GraphQLNonNull @GraphQLArgument(name = "password") String password) {
        Authentication auth = new UsernamePasswordAuthenticationToken(username, password,
                Arrays.asList(new SimpleGrantedAuthority("ROLE_SHOPPER")));

        if (username.equals("root") && password.equals("admin")) {
            SecurityContext securityContext = SecurityContextHolder.getContext();
            securityContext.setAuthentication(auth);
            HttpSession session = request.getSession();
            session.setAttribute("SPRING_SECURITY_CONTEXT", securityContext);

            Cookie authCookie = new Cookie("SHOPPER_LOGGED_IN", Boolean.TRUE.toString());
            authCookie.setMaxAge(60 * 60 * 8);
            authCookie.setSecure(true);
            response.addCookie(authCookie);

            return GraphQlResponse.success(null);
        } else {
            return GraphQlResponse.fail("Falsche Logindaten");
        }
    }

}
