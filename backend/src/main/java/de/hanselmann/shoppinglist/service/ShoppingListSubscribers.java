package de.hanselmann.shoppinglist.service;

import org.reactivestreams.Publisher;

import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListSubscribers {

    Publisher<ShoppingListItem> addSubscriber();

    void notifyItemChanged(ShoppingListItem changedShoppingListItem);

}