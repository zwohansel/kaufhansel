package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;

@Service
public class EMailService {

    private static final String SENDER_EMAIL_ADDRESS = "noreply.kaufhansel@zwohansel.de";
    private static final String EMAIL_FOOTER = "\nDeine ZwoHansel\n\nhttps://www.zwohansel.de";
    private final JavaMailSender emailSender;

    @Autowired
    public EMailService(JavaMailSender emailSender) {
        this.emailSender = emailSender;
    }

    public void sendRegistrationActivationMail(PendingRegistration pendingRegistration) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(SENDER_EMAIL_ADDRESS);
        message.setTo(pendingRegistration.getEmailAddress());
        message.setSubject("Schließe deine Registrierung beim Kaufhansel ab");
        message.setText(MessageFormat.format(
                "Hi {0},"
                        + "\n\nfolge dem Link um deine Registrierung beim Kaufhansel abzuschließen:"
                        + "\nhttps://zwohansel.de/kaufhansel/activate/{1}"
                        + "\n\nViel Spaß mit dem Kaufhansel."
                        + EMAIL_FOOTER,
                pendingRegistration.getUserName(),
                pendingRegistration.getActivationCode()));
        emailSender.send(message);
    }

    public void sendInviteMail(String toAddress, String activationCode, String from) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(SENDER_EMAIL_ADDRESS);
        message.setTo(toAddress);
        message.setSubject(MessageFormat.format("{0} lädt dich zum Kaufhansel ein", from));
        message.setText(MessageFormat.format("Hi,"
                + "\n\n{0} lädt dich ein den Kaufhansel zu verwenden."
                + "\nMit dem Kaufhansel kannst du ganz einfach Einkaufslisten erstellen und sie mit deinen Freunden teilen."
                + "\nGehe auf https://www.zwohansel.de/kaufhansel/download und lade dir die App für dein "
                + "Telefon oder für deinen PC herunter."
                // + "\nWenn du den Kaufhansel lieber im Web nutzen willst gehe auf
                // https://www.zwohansel.de/kaufhansel."
                + "\nNutze den folgenden Code um dich zu registrieren:"
                + "\n\n{1}"
                + "\n\nViel Spaß beim Einkaufen!"
                + EMAIL_FOOTER, from, activationCode));
        emailSender.send(message);
    }

}
