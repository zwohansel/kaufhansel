package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * Reference from a user to a shopping list.
 */
@Entity
@Table(name = "LIST_PERMISSIONS")
public class ShoppingListPermissions {

    @Id
    private long id;

    @Column(name = "ROLE", nullable = false)
    private ShoppingListRole role;

    @Column(name = "CREATED_AT", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "USER_ID", nullable = false)
    private ShoppingListUser user;

    public ShoppingListPermissions() {

    }

    public ShoppingListPermissions(ShoppingListRole role, LocalDateTime createdAt) {
        this.role = role;
        this.createdAt = createdAt;
    }

    public long getId() {
        return id;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public ShoppingListUser getUser() {
        return user;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

}
