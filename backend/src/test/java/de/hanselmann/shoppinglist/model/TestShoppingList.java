package de.hanselmann.shoppinglist.model;

import java.util.List;

import org.bson.types.ObjectId;

public class TestShoppingList extends ShoppingList {

    public TestShoppingList(ObjectId id, String name, List<ShoppingListItem> items,
            List<ShoppingListUserReference> users) {
        super(id, name, items, users);
    }

}
