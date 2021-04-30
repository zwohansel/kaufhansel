package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.stream.Stream;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ShoppingListUserRepository extends JpaRepository<ShoppingListUser, Long> {
    Optional<ShoppingListUser> findUserByUsername(String username);

    Optional<ShoppingListUser> findUserByEmailAddress(String emailAddress);

    boolean existsByEmailAddress(String emailAddress);

    Stream<ShoppingListUser> findByPasswordResetRequestedAtLessThan(LocalDateTime date);

    default Stream<ShoppingListUser> findExpiredPasswordResetRequests(long olderThanMinutes) {
        return findByPasswordResetRequestedAtLessThan(LocalDateTime.now().minusMinutes(olderThanMinutes));
    }
}
