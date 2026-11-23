package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.ZoneId;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.client.RestTestClient;
import org.springframework.test.web.servlet.client.RestTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.RefreshTokenDto;
import de.hanselmann.shoppinglist.restapi.dto.RequestUserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.UserPasswordResetDto;
import de.hanselmann.shoppinglist.service.TimeService;
import de.hanselmann.shoppinglist.testutils.SmtpGreenMailServerExtension;
import de.hanselmann.shoppinglist.testutils.TimeServiceStub;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class RefreshTokenEndpointTest {
    private static final String REFRESH_PATH = "/api/user/token/refresh";
    private static final String REVOKE_PATH = "/api/user/token/revoke";
    private static final String LISTS_PATH = "/api/shoppinglists";

    @Autowired
    private RestTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @RegisterExtension
    static SmtpGreenMailServerExtension mailServer = new SmtpGreenMailServerExtension();

    @DynamicPropertySource
    static void mailProperties(DynamicPropertyRegistry registry) {
        mailServer.registerMailProperties(registry);
    }

    private static TimeServiceStub timeService = new TimeServiceStub();

    @BeforeEach
    public void resetTimeService() {
        timeService.reset();
    }

    @TestConfiguration
    public static class TimeServiceTestConfig {

        @Bean
        public TimeService getTimeService() {
            return timeService;
        }

    }

    private ResponseSpec refresh(String refreshToken) {
        return post(REFRESH_PATH, refreshToken);
    }

    private ResponseSpec revoke(String refreshToken) {
        return post(REVOKE_PATH, refreshToken);
    }

    private ResponseSpec post(String path, String refreshToken) {
        RefreshTokenDto dto = new RefreshTokenDto();
        dto.setRefreshToken(refreshToken);
        return webClient.post()
                .uri(path)
                .body(dto)
                .exchange();
    }

    private ResponseSpec getListsWithToken(String accessToken) {
        return webClient.mutate()
                .defaultHeader("AUTHORIZATION", "Bearer " + accessToken)
                .build()
                .get()
                .uri(LISTS_PATH)
                .exchange();
    }

    @Test
    public void loginReturnsRefreshToken() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");
        assertThat(userInfo.getRefreshToken()).isNotEmpty();
        assertThat(userInfo.getRefreshToken()).isNotEqualTo(userInfo.getToken());
    }

    @Test
    public void loginReturnsExpirationDateOfAccessToken() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        long expectedExpiration = timeService.now().plusHours(8).atZone(ZoneId.systemDefault()).toEpochSecond();
        assertThat(userInfo.getTokenExpiresAt()).isEqualTo(expectedExpiration);
    }

    @Test
    public void refreshTokenReturnsNewAccessToken() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        ShoppingListUserInfoDto refreshedInfo = refresh(userInfo.getRefreshToken())
                .expectStatus().is2xxSuccessful()
                .expectBody(ShoppingListUserInfoDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(refreshedInfo.getEmailAddress()).isEqualTo(LoginTest.ALICE_EMAIL);
        assertThat(refreshedInfo.getId()).isEqualTo(userInfo.getId());
        assertThat(refreshedInfo.getToken()).isNotEmpty();
        // The refresh token is only handed out once: the client already has it
        assertThat(refreshedInfo.getRefreshToken()).isNull();

        getListsWithToken(refreshedInfo.getToken()).expectStatus().is2xxSuccessful();
    }

    @Test
    public void refreshTokenCanBeUsedMoreThanOnce() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        refresh(userInfo.getRefreshToken()).expectStatus().is2xxSuccessful();
        refresh(userInfo.getRefreshToken()).expectStatus().is2xxSuccessful();
    }

    @Test
    public void refreshFailsIfTokenIsUnknown() {
        refresh("NotARefreshToken").expectStatus().isUnauthorized();
    }

    @Test
    public void refreshFailsIfAccessTokenIsUsedAsRefreshToken() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");
        refresh(userInfo.getToken()).expectStatus().isUnauthorized();
    }

    @Test
    public void refreshTokenDoesNotAuthenticateRequests() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");
        getListsWithToken(userInfo.getRefreshToken()).expectStatus().isUnauthorized();
    }

    @Test
    public void refreshFailsIfTokenWasNotUsedForTooLong() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        timeService.setNow(timeService.now().plusDays(366));

        refresh(userInfo.getRefreshToken()).expectStatus().isUnauthorized();
    }

    @Test
    public void everyUseOfTheRefreshTokenExtendsItsLifetime() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        // The token would have expired long ago if its lifetime was not extended
        for (int i = 0; i < 4; i++) {
            timeService.setNow(timeService.now().plusDays(300));
            refresh(userInfo.getRefreshToken()).expectStatus().is2xxSuccessful();
        }

        timeService.setNow(timeService.now().plusDays(366));
        refresh(userInfo.getRefreshToken()).expectStatus().isUnauthorized();
    }

    @Test
    public void accessTokenCanBeRefreshedAfterItHasExpired() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        timeService.setNow(timeService.now().plusHours(9));
        getListsWithToken(userInfo.getToken()).expectStatus().isUnauthorized();

        ShoppingListUserInfoDto refreshedInfo = refresh(userInfo.getRefreshToken())
                .expectStatus().is2xxSuccessful()
                .expectBody(ShoppingListUserInfoDto.class)
                .returnResult()
                .getResponseBody();

        assertThat(refreshedInfo.getTokenExpiresAt()).isGreaterThan(userInfo.getTokenExpiresAt());
        getListsWithToken(refreshedInfo.getToken()).expectStatus().is2xxSuccessful();
    }

    @Test
    public void revokedRefreshTokenCannotBeUsedAnymore() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        revoke(userInfo.getRefreshToken()).expectStatus().isNoContent();

        refresh(userInfo.getRefreshToken()).expectStatus().isUnauthorized();
        // The access token stays valid until it expires
        getListsWithToken(userInfo.getToken()).expectStatus().is2xxSuccessful();
    }

    @Test
    public void revokeSucceedsIfTokenIsUnknown() {
        revoke("NotARefreshToken").expectStatus().isNoContent();
    }

    @Test
    public void refreshTokenIsRevokedIfPasswordIsReset() {
        ShoppingListUserInfoDto userInfo = LoginTest.login(webClient, LoginTest.ALICE_EMAIL, "alice");

        RequestUserPasswordResetDto requestReset = new RequestUserPasswordResetDto();
        requestReset.setEmailAddress(LoginTest.ALICE_EMAIL);
        webClient.post()
                .uri("/api/user/password/requestreset")
                .body(requestReset)
                .exchange()
                .expectStatus().is2xxSuccessful();

        String resetCode = userRepository.findUserByEmailAddress(LoginTest.ALICE_EMAIL)
                .flatMap(user -> user.getPasswordResetCode())
                .orElseThrow();

        UserPasswordResetDto reset = new UserPasswordResetDto();
        reset.setEmailAddress(LoginTest.ALICE_EMAIL);
        reset.setResetCode(resetCode);
        reset.setPassword("newAlicePassword");
        webClient.post()
                .uri("/api/user/password/reset")
                .body(reset)
                .exchange()
                .expectStatus().is2xxSuccessful();

        refresh(userInfo.getRefreshToken()).expectStatus().isUnauthorized();
        getListsWithToken(userInfo.getToken()).expectStatus().isUnauthorized();
    }
}
