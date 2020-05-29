package de.hanselmann.shoppinglist.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.view.RedirectView;

/**
 * The frontend uses react router to rewrite the browser history. E.g. to
 * ".../login" if the user is not authenticated. If the user refreshes the login
 * page we need a redirect to the root page instead of an 404.
 */
@Controller
public class ShoppingListLoginRedirectController {

    @GetMapping("/login")
    public RedirectView handleLoginRequest() {
        return new RedirectView("/");
    }

}
