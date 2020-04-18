package de.hanselmann.shoppinglist.service;

import java.util.Collection;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import graphql.schema.DataFetcher;

public interface ShoppingListDataFetchers {

	DataFetcher<Collection<ShoppingListItem>> getItems();

	DataFetcher<String> getItemId();

	DataFetcher<ShoppingListItem> createItem();

	DataFetcher<ShoppingListItem> changeItemCheckedState();

	DataFetcher<String> deleteItem();

	DataFetcher<Boolean> clearItems();

}
