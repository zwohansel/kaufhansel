package de.hanselmann.shoppinglist.service;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLQuery;

public class ShoppingListItemChangedEvent {

    private final ShoppingListItemChangedEventType type;
    private final ShoppingListItem item;

    private ShoppingListItemChangedEvent(ShoppingListItemChangedEventType type, ShoppingListItem item) {
        this.type = type;
        this.item = item;
    }

    public static ShoppingListItemChangedEvent changedItem(ShoppingListItem changedItem) {
        return new ShoppingListItemChangedEvent(ShoppingListItemChangedEventType.ITEM_CHANGED, changedItem);
    }

    public static ShoppingListItemChangedEvent deletedItem(ShoppingListItem changedItem) {
        return new ShoppingListItemChangedEvent(ShoppingListItemChangedEventType.ITEM_DELETED, changedItem);
    }

    public static ShoppingListItemChangedEvent createdItem(ShoppingListItem changedItem) {
        return new ShoppingListItemChangedEvent(ShoppingListItemChangedEventType.ITEM_CREATED, changedItem);
    }

    @GraphQLQuery(name = "type")
    public @GraphQLNonNull ShoppingListItemChangedEventType getType() {
        return type;
    }

    @GraphQLQuery(name = "item")
    public @GraphQLNonNull ShoppingListItem getItem() {
        return item;
    }

}
