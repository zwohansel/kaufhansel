package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.service.TimeService;
import de.hanselmann.shoppinglist.testutils.SmtpGreenMailServerExtension;
import de.hanselmann.shoppinglist.testutils.TimeServiceStub;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class ActivationEndpointTest {

    private static final String PATH = "/api/user/activate/{code}";

    @Autowired
    private WebTestClient webClient;

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

    public static ResponseSpec activateUser(WebTestClient webClient, String activationCode) {
        return webClient.get()
                .uri(PATH, activationCode)
                .exchange();
    }

    @Test
    public void userCanLoginAfterActivation() throws MessagingException, IOException {
        String newUserEMail = "foo@bar.de";
        String newUserPassword = "12345678";
        String newUserName = "Foobar";
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress(newUserEMail);
        registrationData.setUserName(newUserName);
        registrationData.setPassword(newUserPassword);
        RegistrationResultDto result = RegisterEndpointTest.registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.SUCCESS);

        assertThat(mailServer.getReceivedMessages()).hasSize(1);
        MimeMessage message = mailServer.getReceivedMessages()[0];
        String activationCode = RegisterEndpointTest.getActivationCodeFromMail(message);
        activateUser(webClient, activationCode)
                .expectStatus()
                .is3xxRedirection()
                .expectHeader()
                .location("/kaufhansel/registration_success.html");

        ShoppingListUserInfoDto newUserInfo = LoginTest.login(webClient, newUserEMail, newUserPassword);
        assertThat(newUserInfo.getUsername()).isEqualTo(newUserName);
        assertThat(newUserInfo.getEmailAddress()).isEqualTo(newUserEMail);
    }

    @Test
    public void activationCodeCanNotBeUsedTwice() throws IOException, MessagingException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("foo@bar.de");
        registrationData.setUserName("Foobar");
        registrationData.setPassword("12345678");
        RegistrationResultDto result = RegisterEndpointTest.registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.SUCCESS);

        assertThat(mailServer.getReceivedMessages()).hasSize(1);
        MimeMessage message = mailServer.getReceivedMessages()[0];
        String activationCode = RegisterEndpointTest.getActivationCodeFromMail(message);
        // first activation should succeed
        activateUser(webClient, activationCode)
                .expectStatus()
                .is3xxRedirection()
                .expectHeader()
                .location("/kaufhansel/registration_success.html");
        // second activation should fail
        activateUser(webClient, activationCode)
                .expectStatus()
                .is3xxRedirection()
                .expectHeader()
                .location("/kaufhansel/registration_failure.html");
    }

    @Test
    public void activationFailsIfExpired() throws IOException, MessagingException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("foo@bar.de");
        registrationData.setUserName("Foobar");
        registrationData.setPassword("12345678");
        RegistrationResultDto result = RegisterEndpointTest.registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.SUCCESS);

        assertThat(mailServer.getReceivedMessages()).hasSize(1);
        MimeMessage message = mailServer.getReceivedMessages()[0];
        String activationCode = RegisterEndpointTest.getActivationCodeFromMail(message);

        // Set the current time to one nanosecond after the expiration time
        timeService.setNow(timeService.now().plusWeeks(PendingRegistration.EXPIRES_IN_WEEKS).plusNanos(1));
        activateUser(webClient, activationCode)
                .expectStatus()
                .is3xxRedirection()
                .expectHeader()
                .location("/kaufhansel/registration_failure.html");
    }

}
