package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListUser;

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
                + "\n\n{0} lädt dich zum Kaufhansel ein."
                + "\nMit dem Kaufhansel kannst du ganz einfach Einkaufslisten erstellen und sie mit deinen Freunden teilen."
                + "\nGehe auf https://www.zwohansel.de/kaufhansel/download und lade dir die App für dein "
                + "Telefon oder für deinen PC herunter."
                // + "\nWenn du den Kaufhansel lieber im Web nutzen willst gehe auf
                // https://www.zwohansel.de/kaufhansel."
                + "\nNutze den folgenden Code um dich zu registrieren:"
                + "\n\n{1}\n"
                + EMAIL_FOOTER, from, activationCode));
        emailSender.send(message);
    }

    public void sendWelcomeEmail(ShoppingListUser user) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(SENDER_EMAIL_ADDRESS);
        message.setTo(user.getEmailAddress());
        message.setSubject(MessageFormat.format("Willkommen beim Kaufhansel {0}", user.getUsername()));
        message.setText(MessageFormat.format("Herzlichen Glückwunsch {0},"
                + "\n\ndu hast dich erfolgreich beim Kaufhansel registriert."
                + "\nMit deiner Email-Addresse und deinem Passwort kannst du dich nun anmelden."
                + "\n\nViel Spaß beim Einkaufen!"
                + EMAIL_FOOTER, user.getUsername()));
        emailSender.send(message);
    }

    public void sendPasswortResetCodeMail(ShoppingListUser user, String resetCode) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(SENDER_EMAIL_ADDRESS);
        message.setTo(user.getEmailAddress());
        message.setSubject(MessageFormat.format("{0}, möchtest du dein Kennwort für den Kaufhansel zurücksetzen?",
                user.getUsername()));
        message.setText(MessageFormat.format("Hallo {0},"
                + "\n\njeder vergisst mal ein Kennwort. Hier ist dein Wiederherstellungs-Code, um dein Kennwort zu ändern:"
                + "\n\n{1}"
                + "\n\nDer Code ist nur begrenzt gültig, schließe den Vorgang also bald ab! "
                + "Falls du dein Kennwort nicht zurücksetzen möchtest, kannst du diese Nachricht ignorieren."
                + "\n\nViel Spaß beim Einkaufen!"
                + EMAIL_FOOTER, user.getUsername(), resetCode));
        emailSender.send(message);
    }

    public void sendPasswortSuccessfullyChangedMail(ShoppingListUser user) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(SENDER_EMAIL_ADDRESS);
        message.setTo(user.getEmailAddress());
        message.setSubject(MessageFormat.format("{0}, du hast dein Kennwort für den Kaufhansel geändert",
                user.getUsername()));
        message.setText(MessageFormat.format("Hallo {0},"
                + "\n\ndu hast dein Kennwort für den Kaufhansel erfolgreich geändert."
                + "\n\nFalls du dein Kennwort nicht eben geändert hast, geht irgendwas Merkwürdiges vor. "
                + "Dann solltest du dein Kennwort für den Kaufhansel jetzt ändern."
                + "\n\nViel Spaß beim Einkaufen!"
                + EMAIL_FOOTER, user.getUsername()));
        emailSender.send(message);
    }

}
