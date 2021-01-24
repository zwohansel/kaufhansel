package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ShoppingListUserRepository extends MongoRepository<ShoppingListUser, ObjectId> {
    Optional<ShoppingListUser> findUserByUsername(String username);

    Optional<ShoppingListUser> findUserByEmailAddress(String emailAddress);
}
