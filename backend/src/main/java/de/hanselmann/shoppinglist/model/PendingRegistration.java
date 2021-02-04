package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class PendingRegistration {
    @Id
    private ObjectId id;
    private String emailAddress;
    private String userName;
    private String password;
    private String activationCode;
    private ObjectId invitedBy;
    private List<ObjectId> invitedToShoppingLists = new ArrayList<>();
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

    public boolean isNotExpired() {
        return !isExpired();
    }

    public ObjectId getInvitedBy() {
        return invitedBy;
    }

    public List<ObjectId> getInvitedToShoppingLists() {
        return Collections.unmodifiableList(invitedToShoppingLists);
    }

}
