package de.hanselmann.shoppinglist.service;

import org.reactivestreams.Publisher;

import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListSubscribers {

    Publisher<ShoppingListItemChangedEvent> addSubscriber();

    void notifyItemChanged(ShoppingListItem item);

    void notifyItemCreated(ShoppingListItem item);

    void notifyItemDeleted(ShoppingListItem item);

}