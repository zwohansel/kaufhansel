package de.hanselmann.shoppinglist.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemRepository extends MongoRepository<ShoppingListItem, String> {
    @Override
    public Optional<ShoppingListItem> findById(String id);

    public List<ShoppingListItem> findByChecked(Boolean checked);
}
