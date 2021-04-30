package de.hanselmann.shoppinglist.model;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

/**
 * Reference from a user to a shopping list.
 */
@Entity
public class ShoppingListReference {

    @Id
    private long id;
    private long shoppingListId;
    private ShoppingListRole role;

    public ShoppingListReference() {

    }

    public ShoppingListReference(long shoppingListId, ShoppingListRole role) {
        this.shoppingListId = shoppingListId;
        this.role = role;
    }

    public long getId() {
        return id;
    }

    public long getShoppingListId() {
        return shoppingListId;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

}
