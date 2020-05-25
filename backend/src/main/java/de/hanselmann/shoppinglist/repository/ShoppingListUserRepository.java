package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ShoppingListUserRepository extends MongoRepository<ShoppingListUser, String> {
    Optional<ShoppingListUser> findUserByUsername(String username);
}
