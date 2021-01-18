package de.hanselmann.shoppinglist.model;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingListReference {

    @Id
    private ObjectId id;
    private ObjectId shoppingListId;

    public ShoppingListReference() {

    }

    public ShoppingListReference(ObjectId shoppingListId) {
        this.shoppingListId = shoppingListId;
    }

    public ObjectId getId() {
        return id;
    }

    public ObjectId getShoppingListId() {
        return shoppingListId;
    }

}
