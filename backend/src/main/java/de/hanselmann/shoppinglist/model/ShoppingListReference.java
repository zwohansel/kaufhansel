package de.hanselmann.shoppinglist.model;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

/**
 * Reference from a user to a shopping list.
 */
public class ShoppingListReference {

    @Id
    private ObjectId id;
    private ObjectId shoppingListId;
    private ShoppingListRole role;

    public ShoppingListReference() {

    }

    public ShoppingListReference(ObjectId shoppingListId, ShoppingListRole role) {
        this.shoppingListId = shoppingListId;
        this.role = role;
    }

    public ObjectId getId() {
        return id;
    }

    public ObjectId getShoppingListId() {
        return shoppingListId;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

}
