package de.hanselmann.shoppinglist.testutils;

import javax.mail.internet.MimeMessage;

import org.junit.jupiter.api.extension.BeforeEachCallback;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.springframework.test.context.DynamicPropertyRegistry;

import com.icegreen.greenmail.util.GreenMail;
import com.icegreen.greenmail.util.ServerSetup;

public class SmtpGreenMailServerExtension implements BeforeEachCallback {

    private final String email;
    private final String username;
    private final String password;
    private final GreenMail greenMail = new GreenMail(ServerSetup.SMTP.dynamicPort());

    public SmtpGreenMailServerExtension() {
        this("test@kaufhansel.test", "username", "password");
    }

    public SmtpGreenMailServerExtension(String email, String username, String password) {
        this.email = email;
        this.username = username;
        this.password = password;
        greenMail.start();
    }

    public void registerMailProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.mail.port", this::getPort);
        registry.add("spring.mail.username", this::getUsername);
        registry.add("spring.mail.password", this::getPassword);
    }

    public int getPort() {
        return greenMail.getSmtp().getPort();
    }

    public String getEmail() {
        return email;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public void changePassword(String password) {
        greenMail.setUser(email, username, password);
    }

    public MimeMessage[] getReceivedMessages() {
        return greenMail.getReceivedMessages();
    }

    @Override
    public void beforeEach(ExtensionContext context) throws Exception {
        greenMail.setUser(email, username, password);
        greenMail.purgeEmailFromAllMailboxes();
    }

}
