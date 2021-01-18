package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;

public interface ShoppingListRepository extends MongoRepository<ShoppingList, ObjectId> {
    @Override
    public Optional<ShoppingList> findById(ObjectId id);
}
