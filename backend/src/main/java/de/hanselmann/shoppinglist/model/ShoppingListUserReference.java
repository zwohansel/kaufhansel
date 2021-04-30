package de.hanselmann.shoppinglist.model;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

/**
 * Reference from a shopping list to a user.
 */
@Entity
public class ShoppingListUserReference {

    @Id
    private long id;
    private long userId;

    public ShoppingListUserReference() {

    }

    public ShoppingListUserReference(long userId) {
        this.userId = userId;
    }

    public long getId() {
        return id;
    }

    public long getUserId() {
        return userId;
    }

}
