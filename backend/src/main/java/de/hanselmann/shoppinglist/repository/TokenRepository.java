package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.Token;
import de.hanselmann.shoppinglist.model.TokenType;

public interface TokenRepository extends JpaRepository<Token, Long> {
    Optional<Token> findByValueAndType(String value, TokenType type);

    int deleteByValueAndType(String value, TokenType type);

    int deleteByUser(ShoppingListUser user);

    int deleteByExpirationDateLessThan(LocalDateTime date);
}
