package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import graphql.schema.DataFetcher;

@Component
public class MongoDBShoppingListDataFetchers implements ShoppingListDataFetchers {

	private int idCounter = 0;
	private List<ShoppingListItem> items = new ArrayList<>();

	@Override
	public DataFetcher<Collection<ShoppingListItem>> getItems() {
		return environment -> items;
	}

	@Override
	public DataFetcher<String> getItemId() {
		return environment -> environment.<ShoppingListItem>getSource().getId();
	}

	@Override
	public DataFetcher<ShoppingListItem> createItem() {
		return environment -> {
			final String name = environment.getArgument("name");
			final ShoppingListItem item = new ShoppingListItem(String.valueOf(idCounter), name);
			idCounter++;
			items.add(item);
			return item;
		};
	}

	@Override
	public DataFetcher<ShoppingListItem> changeItemCheckedState() {
		return environment -> {
			String id = environment.getArgument("id");

			ShoppingListItem item = items.stream().filter(i -> i.getId().equals(id)).findAny()
					.orElseThrow(() -> new IllegalArgumentException(
							MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));

			item.setChecked(environment.getArgument("state"));

			return item;
		};
	}

	@Override
	public DataFetcher<String> deleteItem() {
		return environment -> {
			String id = environment.getArgument("id");
			items.removeIf(item -> item.getId().equals(id));
			return id;
		};
	}

	@Override
	public DataFetcher<Boolean> clearItems() {
		return environment -> {
			items.clear();
			return true;
		};
	}

}
