package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.mail.Message.RecipientType;
import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.RegisterExtension;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.testutils.SmtpGreenMailServerExtension;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class RegisterEndpointTest {

    private static final String PATH = "/api/user/register";

    @Autowired
    private WebTestClient webClient;

    @RegisterExtension
    static SmtpGreenMailServerExtension mailServer = new SmtpGreenMailServerExtension();

    @DynamicPropertySource
    static void mailProperties(DynamicPropertyRegistry registry) {
        mailServer.registerMailProperties(registry);
    }

    public static RegistrationResultDto registerUser(WebTestClient webClient, RegistrationDataDto registrationData) {
        return webClient.post()
                .uri(PATH)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(registrationData)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(RegistrationResultDto.class)
                .returnResult()
                .getResponseBody();
    }

    public static String getActivationCodeFromMail(MimeMessage message) throws IOException, MessagingException {
        String content = message.getContent().toString();
        var pattern = Pattern.compile("https://zwohansel.de/kaufhansel/api/user/activate/(?<code>[a-zA-Z0-9_-]+)");
        Matcher activationCodeMatcher = pattern.matcher(content);
        if (!activationCodeMatcher.find()) {
            throw new RuntimeException("No activation code in mail:\n" + content);
        }
        return activationCodeMatcher.group("code");
    }

    @Test
    public void emailWithActivationCodeIsSentOnRegister() throws MessagingException, IOException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("foo@bar.de");
        registrationData.setUserName("Foo");
        registrationData.setPassword("12345678");
        RegistrationResultDto result = registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.SUCCESS);

        assertThat(mailServer.getReceivedMessages()).hasSize(1);
        MimeMessage message = mailServer.getReceivedMessages()[0];
        assertThat(message.getRecipients(RecipientType.TO)).hasSize(1);
        assertThat(message.getRecipients(RecipientType.TO)[0]).hasToString("foo@bar.de");
        String activationCode = getActivationCodeFromMail(message);
        assertThat(activationCode).hasSizeGreaterThan(20);
    }

    @Test
    public void returnsStatusEMailInvalidIfEMailAlreadyInUse() throws MessagingException, IOException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress(LoginTest.ALICE_EMAIL);
        registrationData.setUserName("Foo");
        registrationData.setPassword("12345678");
        RegistrationResultDto result = registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.EMAIL_INVALID);
    }

    @Test
    public void returnsStatusPasswordInvalidIfPasswordMissing() throws MessagingException, IOException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("no@password.de");
        registrationData.setUserName("Foo");
        RegistrationResultDto result = registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.PASSWORD_INVALID);
    }

    @Test
    public void returnsStatusPasswordInvalidIfPasswordTooShort() throws MessagingException, IOException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("short@password.de");
        registrationData.setPassword("1234567");
        registrationData.setUserName("Foo");
        RegistrationResultDto result = registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.PASSWORD_INVALID);
    }

    @Test
    public void returnsStatusFailedIfEMailServerPasswordInvalid() throws MessagingException, IOException {
        RegistrationDataDto registrationData = new RegistrationDataDto();
        registrationData.setEmailAddress("email-server@down.de");
        registrationData.setPassword("123456789");
        registrationData.setUserName("Foo");
        mailServer.changePassword("invalid");
        RegistrationResultDto result = registerUser(webClient, registrationData);
        assertThat(result.getStatus()).isEqualTo(RegistrationResultDto.Status.FAILURE);
    }
}
