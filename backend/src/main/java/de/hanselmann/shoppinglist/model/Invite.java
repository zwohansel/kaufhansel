package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class Invite {
    @Id
    private ObjectId id;
    private String code;
    private ObjectId generatedByUser;
    private LocalDateTime generatedAt;
    private String inviteeEmailAddress;
    private List<ObjectId> invitedToShoppingLists = new ArrayList<>();

    public static Invite create(String code, ShoppingListUser invitor) {
        return createForEmailAddress(code, invitor, null);
    }

    public static Invite createForEmailAddress(String code, ShoppingListUser invitor, String inviteeEmailAddress) {
        return new Invite(code, invitor.getId(), LocalDateTime.now(), inviteeEmailAddress);
    }

    public static Invite createForEmailAddressAndList(
            String code,
            ShoppingListUser invitor,
            String inviteeEmailAddress,
            ObjectId shoppingListId) {
        Invite invite = createForEmailAddress(code, invitor, inviteeEmailAddress);
        invite.invitedToShoppingLists.add(shoppingListId);
        return invite;
    }

    private Invite(String code, ObjectId generatedByUserId, LocalDateTime generatedAt, String inviteeEmailAddress) {
        this.code = code;
        this.generatedByUser = generatedByUserId;
        this.generatedAt = generatedAt;
        this.inviteeEmailAddress = inviteeEmailAddress != null ? inviteeEmailAddress.toLowerCase().strip() : null;
    }

    public Invite() {
        this(null, null, null, null);
    }

    private Invite(Invite invite, String emailAddress) {
        this.code = invite.code;
        this.generatedByUser = invite.generatedByUser;
        this.generatedAt = invite.generatedAt;
        this.inviteeEmailAddress = emailAddress;
        this.invitedToShoppingLists.addAll(invite.invitedToShoppingLists);

    }

    public Invite forEmailAddress(String emailAddress) {
        return new Invite(this, emailAddress);
    }

    public ObjectId getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public ObjectId getGeneratedByUser() {
        return generatedByUser;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public String getInviteeEmailAddress() {
        return inviteeEmailAddress;
    }

    public List<ObjectId> getInvitedToShoppingLists() {
        return Collections.unmodifiableList(invitedToShoppingLists);
    }

}
