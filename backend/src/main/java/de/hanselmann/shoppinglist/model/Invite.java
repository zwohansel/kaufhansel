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
    private final List<ObjectId> invitedToShoppingLists = new ArrayList<>();

    public static Invite create(String code, ShoppingListUser invitor) {
        return new Invite(code, invitor.getId(), LocalDateTime.now());
    }

    public static Invite createForEmailAddress(String code, ShoppingListUser invitor, String inviteeEmailAddress) {
        Invite invite = create(code, invitor);
        invite.inviteeEmailAddress = inviteeEmailAddress;
        return invite;
    }

    public static Invite createForEmailAddressAndList(String code, ShoppingListUser invitor, String inviteeEmailAddress,
            ObjectId shoppingListId) {
        Invite invite = createForEmailAddress(code, invitor, inviteeEmailAddress);
        invite.invitedToShoppingLists.add(shoppingListId);
        return invite;
    }

    public Invite() {
    }

    private Invite(String code, ObjectId generatedByUserId, LocalDateTime generatedAt) {
        this.code = code;
        this.generatedByUser = generatedByUserId;
        this.generatedAt = generatedAt;
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
