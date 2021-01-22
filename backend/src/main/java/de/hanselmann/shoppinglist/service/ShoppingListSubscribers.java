package de.hanselmann.shoppinglist.service;

import java.util.List;

import org.bson.types.ObjectId;
import org.reactivestreams.Publisher;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListSubscribers {

    Publisher<List<ShoppingListItemChangedEvent>> addSubscriber(ObjectId userId);

    void notifyItemsChanged(ShoppingList shoppingList, List<ShoppingListItem> items);

    void notifyItemsCreated(ShoppingList shoppingList, List<ShoppingListItem> items);

    void notifyItemsDeleted(ShoppingList shoppingList, List<ShoppingListItem> items);

}