package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ShoppingListUserRepository extends MongoRepository<ShoppingListUser, ObjectId> {
    Optional<ShoppingListUser> findUserByUsername(String username);

    Optional<ShoppingListUser> findUserByEmailAddress(String emailAddress);

    boolean existsByEmailAddress(String emailAddress);

    Stream<ShoppingListUser> findByPasswordResetRequestedAtLessThan(LocalDateTime date);

    default Stream<ShoppingListUser> findExpiredPasswordResetRequests(long olderThanMinutes) {
        return findByPasswordResetRequestedAtLessThan(LocalDateTime.now().minusMinutes(olderThanMinutes));
    }
}
