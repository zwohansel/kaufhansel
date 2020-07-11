package de.hanselmann.shoppinglist.service;

import java.util.List;

import org.reactivestreams.Publisher;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListSubscribers {

    Publisher<List<ShoppingListItemChangedEvent>> addSubscriber(String userId);

    void notifyItemsChanged(ShoppingList shoppingList, List<ShoppingListItem> items);

    void notifyItemsCreated(ShoppingList shoppingList, List<ShoppingListItem> items);

    void notifyItemsDeleted(ShoppingList shoppingList, List<ShoppingListItem> items);

}