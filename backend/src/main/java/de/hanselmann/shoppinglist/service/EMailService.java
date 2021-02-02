package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;

@Service
public class EMailService {

    private final JavaMailSender emailSender;

    @Autowired
    public EMailService(JavaMailSender emailSender) {
        this.emailSender = emailSender;
    }

    public void sendRegistrationActivationMail(PendingRegistration pendingRegistration) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("noreply.kaufhansel@zwohansel.de");
        message.setTo(pendingRegistration.getEmailAddress());
        message.setSubject("Schließe deine Registrierung beim Kaufhansel ab");
        message.setText(MessageFormat.format(
                "Hi {0},"
                        + "\n\nfolge dem Link um deine Registrierung beim Kaufhansel abzuschließen:"
                        + "\nhttps://zwohansel.de/kaufhansel/activate/{1}"
                        + "\n\nViel Spaß mit dem Kaufhansel."
                        + "\nDeine ZwoHansel"
                        + "\n\nhttps://www.zwohansel.de",
                pendingRegistration.getUserName(),
                pendingRegistration.getActivationCode()));
        emailSender.send(message);
    }

}
