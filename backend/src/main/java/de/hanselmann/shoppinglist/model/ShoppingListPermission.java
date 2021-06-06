package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.MapsId;
import javax.persistence.Table;

/**
 * Reference from a user to a shopping list.
 */
@Entity
@Table(name = "LIST_PERMISSIONS")
public class ShoppingListPermission {

    @EmbeddedId
    private ShoppingListPermissionKey id;

    @Column(name = "ROLE", nullable = false)
    private ShoppingListRole role;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @ManyToOne
    @MapsId("shoppingListUserId")
    @JoinColumn(name = "USER_ID")
    private ShoppingListUser user;

    @ManyToOne
    @MapsId("shoppingListId")
    @JoinColumn(name = "LIST_ID")
    private ShoppingList list;

    protected ShoppingListPermission() {

    }

    public ShoppingListPermission(ShoppingListRole role, ShoppingListUser user, ShoppingList list,
            LocalDateTime createdAt) {
        this.role = role;
        this.createdAt = createdAt;
        this.user = user;
        this.list = list;
    }

    public ShoppingListPermissionKey getId() {
        return id;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

    public ShoppingListUser getUser() {
        return user;
    }

    public ShoppingList getList() {
        return list;
    }

}
