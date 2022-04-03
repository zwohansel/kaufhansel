package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.restapi.dto.LoginDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.web.reactive.server.WebTestClient;

import static org.assertj.core.api.Assertions.assertThat;

@WebServerTestWithTestUser
public class LoginTest {
    private static final String PATH = "/api/user/login";
    private static final String TEST_USER_EMAIL = "test@test.test";
    private static final String TEST_USER_PASSWORD = "test";

    @Autowired
    private WebTestClient webClient;

    public static WebTestClient loggedInClient(WebTestClient webClient) {
        String token = loginAsTestUser(webClient).getToken();
        return webClient.mutate().defaultHeader("AUTHORIZATION", "Bearer " + token).build();
    }

    private static ShoppingListUserInfoDto loginAsTestUser(WebTestClient webClient) {
        LoginDto loginDto = new LoginDto();
        loginDto.setEmailAddress(TEST_USER_EMAIL);
        loginDto.setPassword(TEST_USER_PASSWORD);
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
        ShoppingListUserInfoDto userInfo = loginAsTestUser(webClient);
        assertThat(userInfo.getEmailAddress()).isEqualTo(TEST_USER_EMAIL);
        assertThat(userInfo.getUsername()).isEqualTo("Test User");
        assertThat(userInfo.getToken()).isNotEmpty();
    }
}
