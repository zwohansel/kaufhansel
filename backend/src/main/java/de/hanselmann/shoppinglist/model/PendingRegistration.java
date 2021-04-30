package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class PendingRegistration {
    public static final int EXPIRES_IN_WEEKS = 2;

    @Id
    private long id;
    private String emailAddress;
    private String userName;
    private String password;
    private String activationCode;
    private ShoppingListUser invitedBy;
    private List<Long> invitedToShoppingLists = new ArrayList<>(); // TODO: Listen statt Long
    private LocalDateTime creationDate;

    public static PendingRegistration create(
            Invite invite,
            String userName,
            String encryptedPassword,
            String activationCode) {
        if (invite.getInviteeEmailAddress() == null) {
            throw new IllegalArgumentException("Invitee EMail address must not be null.");
        }

        PendingRegistration pendingRegistration = new PendingRegistration();
        pendingRegistration.emailAddress = invite.getInviteeEmailAddress();
        pendingRegistration.userName = userName;
        pendingRegistration.password = encryptedPassword;
        pendingRegistration.activationCode = activationCode;
        pendingRegistration.invitedBy = invite.getGeneratedByUser();
        pendingRegistration.creationDate = LocalDateTime.now();
        pendingRegistration.invitedToShoppingLists.addAll(invite.getInvitedToShoppingLists());
        return pendingRegistration;
    }

    private PendingRegistration() {
    };

    protected PendingRegistration(long id, String emailAddress, String userName, String password,
            String activationCode, ShoppingListUser invitedBy, List<Long> invitedToShoppingLists,
            LocalDateTime creationDate) {
        this.id = id;
        this.emailAddress = emailAddress;
        this.userName = userName;
        this.password = password;
        this.activationCode = activationCode;
        this.invitedBy = invitedBy;
        this.invitedToShoppingLists = invitedToShoppingLists;
        this.creationDate = creationDate;
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
        return LocalDateTime.now().isAfter(creationDate.plusWeeks(EXPIRES_IN_WEEKS));
    }

    public boolean isNotExpired() {
        return !isExpired();
    }

    public ShoppingListUser getInvitedBy() {
        return invitedBy;
    }

    public List<Long> getInvitedToShoppingLists() {
        return Collections.unmodifiableList(invitedToShoppingLists);
    }

}
