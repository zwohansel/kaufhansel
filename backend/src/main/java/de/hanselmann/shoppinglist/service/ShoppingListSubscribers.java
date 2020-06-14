package de.hanselmann.shoppinglist.service;

import java.util.List;

import org.reactivestreams.Publisher;

import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListSubscribers {

    Publisher<List<ShoppingListItemChangedEvent>> addSubscriber();

    void notifyItemsChanged(List<ShoppingListItem> items);

    void notifyItemsCreated(List<ShoppingListItem> items);

    void notifyItemsDeleted(List<ShoppingListItem> items);

}