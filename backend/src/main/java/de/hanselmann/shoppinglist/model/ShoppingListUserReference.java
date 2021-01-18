package de.hanselmann.shoppinglist.model;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingListUserReference {

    @Id
    private ObjectId id;
    private ObjectId userId;

    public ShoppingListUserReference() {

    }

    public ShoppingListUserReference(ObjectId userId) {
        this.userId = userId;
    }

    public ObjectId getId() {
        return id;
    }

    public ObjectId getUserId() {
        return userId;
    }

}
