package de.hanselmann.shoppinglist.service;

import java.util.Arrays;
import java.util.Optional;

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
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLMutation;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
public class LoginService {
	private final static int TIMEOUT_SECONDS = 60 * 60 * 8;
	
    private final HttpServletRequest request;
    private final HttpServletResponse response;
    private final ShoppingListUserRepository userRepository;

    @Autowired
    public LoginService(HttpServletRequest request, HttpServletResponse response, ShoppingListUserRepository userRepository) {
        this.userRepository = userRepository;
		this.request = request;
        this.response = response;
    }

    @GraphQLMutation
    public @GraphQLNonNull GraphQlResponse<Void> login(
            @GraphQLNonNull @GraphQLArgument(name = "username") String username,
            @GraphQLNonNull @GraphQLArgument(name = "password") String password) {

    	Optional<ShoppingListUser> optionalUser = userRepository.findUserByUsername(username);
        if (optionalUser.isPresent()) {
        	ShoppingListUser user = optionalUser.get();
        	if (isPasswordCorrect(user, password)) {
        		return loginUser(user);
        	}
        }
        
        return GraphQlResponse.fail("Falsche Logindaten");
    }
    
    private boolean isPasswordCorrect(ShoppingListUser user, String password) {
    	return user.getPassword().equals(password);
    }
    
    private GraphQlResponse<Void> loginUser(ShoppingListUser user) {
    	Authentication auth = new UsernamePasswordAuthenticationToken(user.getId(), user.getPassword(),
                Arrays.asList(new SimpleGrantedAuthority("ROLE_SHOPPER")));
    	
            SecurityContext securityContext = SecurityContextHolder.getContext();
            securityContext.setAuthentication(auth);
            HttpSession session = request.getSession();
            session.setAttribute("SPRING_SECURITY_CONTEXT", securityContext);
            session.setMaxInactiveInterval(TIMEOUT_SECONDS);

            Cookie authCookie = new Cookie("SHOPPER_LOGGED_IN", Boolean.TRUE.toString());
            authCookie.setMaxAge(TIMEOUT_SECONDS);
            authCookie.setSecure(true);
            response.addCookie(authCookie);

            return GraphQlResponse.success(null);
    }

}