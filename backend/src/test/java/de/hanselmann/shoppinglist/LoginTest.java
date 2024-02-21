package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.LoginDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class LoginTest {
    private static final String PATH = "/api/user/login";
    public static final String ALICE_EMAIL = "alice@hansel.test";
    private static final String ALICE_PASSWORD = "alice";
    public static final String BOB_EMAIL = "bob@hansel.test";
    private static final String BOB_PASSWORD = "bob";
    public static final String EVE_EMAIL = "eve@hansel.test";
    private static final String EVE_PASSWORD = "eve";

    @Autowired
    private WebTestClient webClient;

    public static WebTestClient loginAsAlice(WebTestClient webClient) {
        return loginAs(webClient, ALICE_EMAIL, ALICE_PASSWORD);
    }

    public static WebTestClient loginAsBob(WebTestClient webClient) {
        return loginAs(webClient, BOB_EMAIL, BOB_PASSWORD);
    }

    public static WebTestClient loginAsEve(WebTestClient webClient) {
        return loginAs(webClient, EVE_EMAIL, EVE_PASSWORD);
    }

    public static WebTestClient loginAs(WebTestClient webClient, String userEmail, String userPassword) {
        String token = login(webClient, userEmail, userPassword).getToken();
        return webClient.mutate().defaultHeader("AUTHORIZATION", "Bearer " + token).build();
    }

    public static ShoppingListUserInfoDto login(WebTestClient webClient, String userEmail, String userPassword) {
        LoginDto loginDto = new LoginDto();
        loginDto.setEmailAddress(userEmail);
        loginDto.setPassword(userPassword);
        return login(webClient, loginDto)
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListUserInfoDto.class)
                .returnResult()
                .getResponseBody();
    }

    private static WebTestClient.ResponseSpec login(WebTestClient webClient, LoginDto loginDto) {
        return webClient.post()
                .uri(PATH)
                .bodyValue(loginDto)
                .exchange();
    }

    @Test
    public void loginSuccessIfEMailAndPasswordCorrect() {
        ShoppingListUserInfoDto userInfo = login(webClient, ALICE_EMAIL, ALICE_PASSWORD);
        assertThat(userInfo.getEmailAddress()).isEqualTo(ALICE_EMAIL);
        assertThat(userInfo.getUsername()).isEqualTo("Alice");
        assertThat(userInfo.getToken()).isNotEmpty();
    }
}
