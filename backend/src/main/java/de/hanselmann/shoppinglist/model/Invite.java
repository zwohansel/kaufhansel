package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class Invite {
    @Id
    private long id;
    private String code;
    private ShoppingListUser generatedByUser;
    private LocalDateTime generatedAt;
    private String inviteeEmailAddress;
    private List<Long> invitedToShoppingLists = new ArrayList<>(); // TODO: Listen statt Long

    public static Invite create(String code, ShoppingListUser invitor) {
        return createForEmailAddress(code, invitor, null);
    }

    public static Invite createForEmailAddress(String code, ShoppingListUser invitor, String inviteeEmailAddress) {
        return new Invite(code, invitor, LocalDateTime.now(), inviteeEmailAddress);
    }

    public static Invite createForEmailAddressAndList(
            String code,
            ShoppingListUser invitor,
            String inviteeEmailAddress,
            long shoppingListId) {
        Invite invite = createForEmailAddress(code, invitor, inviteeEmailAddress);
        invite.invitedToShoppingLists.add(shoppingListId);
        return invite;
    }

    private Invite(String code, ShoppingListUser generatedByUser, LocalDateTime generatedAt,
            String inviteeEmailAddress) {
        this.code = code;
        this.generatedByUser = generatedByUser;
        this.generatedAt = generatedAt;
        this.inviteeEmailAddress = inviteeEmailAddress != null ? inviteeEmailAddress.toLowerCase().strip() : null;
    }

    public Invite() {
        this(null, null, null, null);
    }

    private Invite(Invite invite, String emailAddress) {
        this(invite.code, invite.generatedByUser, invite.generatedAt, emailAddress);
        this.invitedToShoppingLists.addAll(invite.invitedToShoppingLists);
    }

    protected Invite(long id, String code, ShoppingListUser generatedByUser, LocalDateTime generatedAt,
            String inviteeEmailAddress, List<Long> invitedToShoppingLists) {
        this.id = id;
        this.code = code;
        this.generatedByUser = generatedByUser;
        this.generatedAt = generatedAt;
        this.inviteeEmailAddress = inviteeEmailAddress;
        this.invitedToShoppingLists = invitedToShoppingLists;
    }

    public Invite forEmailAddress(String emailAddress) {
        return new Invite(this, emailAddress);
    }

    public long getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public ShoppingListUser getGeneratedByUser() {
        return generatedByUser;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

    public String getInviteeEmailAddress() {
        return inviteeEmailAddress;
    }

    public List<Long> getInvitedToShoppingLists() {
        return Collections.unmodifiableList(invitedToShoppingLists);
    }

}
