package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "LIST_INVITES")
public class ListInvite {
    @Id
    private long id;

    @Column(name = "INVITED_BY", nullable = false)
    private ShoppingListUser invitedBy;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "INVITEE_EMAIL", nullable = false)
    private String inviteeEmailAddress;

    @Column(name = "INVITED_INTO_LIST", nullable = false)
    private ShoppingList list;

    public static ListInvite createForEmailAddressAndList(ShoppingListUser invitedBy, String inviteeEmailAddress,
            ShoppingList list) {
        return createForEmailAddressAndList(invitedBy, LocalDateTime.now(), inviteeEmailAddress, list);
    }

    protected static ListInvite createForEmailAddressAndList(ShoppingListUser invitedBy, LocalDateTime createdAt,
            String inviteeEmailAddress, ShoppingList list) {
        return new ListInvite(invitedBy, createdAt, inviteeEmailAddress, list);
    }

    private ListInvite(ShoppingListUser invitedBy, LocalDateTime generatedAt, String inviteeEmailAddress,
            ShoppingList list) {
        this.invitedBy = invitedBy;
        this.createdAt = generatedAt;
        this.list = list;
        this.inviteeEmailAddress = inviteeEmailAddress.toLowerCase().strip();
    }

    public ListInvite() {
        this(null, null, "", null);
    }

    public long getId() {
        return id;
    }

    public ShoppingListUser getGeneratedByUser() {
        return invitedBy;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public String getInviteeEmailAddress() {
        return inviteeEmailAddress;
    }

    public ShoppingList getShoppingList() {
        return list;
    }

}
