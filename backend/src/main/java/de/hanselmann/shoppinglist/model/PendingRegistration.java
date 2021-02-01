package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class PendingRegistration {
    @Id
    private ObjectId id;
    private String emailAddress;
    private String userName;
    private String password;
    private String activationCode;
    private LocalDateTime creationDate;

    public static PendingRegistration create(String emailAddress, String userName, String encryptedPassword,
            String activationCode) {
        PendingRegistration pendingRegistration = new PendingRegistration();
        pendingRegistration.emailAddress = emailAddress;
        pendingRegistration.userName = userName;
        pendingRegistration.password = encryptedPassword;
        pendingRegistration.activationCode = activationCode;
        pendingRegistration.creationDate = LocalDateTime.now();
        return pendingRegistration;
    }

    public ObjectId getId() {
        return id;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

    public String getUserName() {
        return userName;
    }

    public String getPassword() {
        return password;
    }

    public String getActivationCode() {
        return activationCode;
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(creationDate.plusWeeks(2));
    }

}
