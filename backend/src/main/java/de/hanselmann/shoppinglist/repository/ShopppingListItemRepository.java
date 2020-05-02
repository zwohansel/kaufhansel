package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShopppingListItemRepository extends MongoRepository<ShoppingListItem, String> {
	public Optional<ShoppingListItem> findById(String id);
}
