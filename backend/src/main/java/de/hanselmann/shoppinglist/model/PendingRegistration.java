package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "PENDING_REGISTRATION")
public class PendingRegistration {
    public static final int EXPIRES_IN_WEEKS = 2;

    @Id
    private long id;

    @Column(name = "EMAIL", nullable = false, unique = true)
    private String emailAddress;

    @Column(name = "USERNAME", nullable = false)
    private String userName;

    @Column(name = "PASSWORD", nullable = false)
    private String password;

    @Column(name = "ACTIVATION_CODE", nullable = false)
    private String activationCode;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime creationAt;

    public static PendingRegistration create(
            String emailAddress,
            String userName,
            String encryptedPassword,
            String activationCode) {
        var pendingRegistration = new PendingRegistration();
        pendingRegistration.emailAddress = emailAddress;
        pendingRegistration.userName = userName;
        pendingRegistration.password = encryptedPassword;
        pendingRegistration.activationCode = activationCode;
        pendingRegistration.creationAt = LocalDateTime.now();
        return pendingRegistration;
    }

    private PendingRegistration() {
    }

    public long getId() {
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
        return LocalDateTime.now().isAfter(creationAt.plusWeeks(EXPIRES_IN_WEEKS));
    }

    public boolean isNotExpired() {
        return !isExpired();
    }

}
