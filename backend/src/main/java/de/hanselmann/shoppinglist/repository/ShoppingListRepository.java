package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;

public interface ShoppingListRepository extends MongoRepository<ShoppingList, String> {
    @Override
    public Optional<ShoppingList> findById(String id);
}
