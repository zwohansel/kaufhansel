package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.Collection;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.repository.ShopppingListItemRepository;
import graphql.schema.DataFetcher;

@Component
public class MongoDBShoppingListDataFetchers implements ShoppingListDataFetchers {

	private ShopppingListItemRepository shoppingListRepository;
	
	@Autowired
	public MongoDBShoppingListDataFetchers(ShopppingListItemRepository shoppingListRepository) {
		this.shoppingListRepository = shoppingListRepository;
	}

	@Override
	public DataFetcher<Collection<ShoppingListItem>> getItems() {
		return environment -> shoppingListRepository.findAll();
	}

	@Override
	public DataFetcher<String> getItemId() {
		return environment -> environment.<ShoppingListItem>getSource().getId();
	}

	@Override
	public DataFetcher<ShoppingListItem> createItem() {
		return environment -> {
			final String name = environment.getArgument("name");
			final ShoppingListItem item = new ShoppingListItem(name);
			return shoppingListRepository.save(item);
		};
	}

	@Override
	public DataFetcher<ShoppingListItem> changeItemCheckedState() {
		return environment -> {
			String id = environment.getArgument("id");
			boolean state = environment.getArgument("state");

			ShoppingListItem item = shoppingListRepository.findById(id).orElseThrow(() -> new IllegalArgumentException(
							MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));
			item.setChecked(state);
			return item;
		};
	}

	@Override
	public DataFetcher<String> deleteItem() {
		return environment -> {
			String id = environment.getArgument("id");
			shoppingListRepository.deleteById(id);
			return id;
		};
	}

	@Override
	public DataFetcher<Boolean> clearItems() {
		return environment -> {
			shoppingListRepository.deleteAll();
			return true;
		};
	}

}
