package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "LIST_INVITES")
public class ListInvite {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "INVITED_BY", nullable = false)
    private ShoppingListUser invitedBy;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "INVITEE_EMAIL", nullable = false)
    private String inviteeEmailAddress;

    @ManyToOne
    @JoinColumn(name = "INVITED_INTO_LIST", nullable = false)
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

    public Long getId() {
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
