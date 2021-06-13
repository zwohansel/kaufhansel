package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ShoppingListUserRepository extends JpaRepository<ShoppingListUser, Long> {
    Optional<ShoppingListUser> findUserByUsername(String username);

    Optional<ShoppingListUser> findUserByEmailAddress(String emailAddress);

    boolean existsByEmailAddress(String emailAddress);

    List<ShoppingListUser> findByPasswordResetRequestedAtLessThan(LocalDateTime date);

    default List<ShoppingListUser> findExpiredPasswordResetRequests(long olderThanMinutes) {
        return findByPasswordResetRequestedAtLessThan(LocalDateTime.now().minusMinutes(olderThanMinutes));
    }
}
