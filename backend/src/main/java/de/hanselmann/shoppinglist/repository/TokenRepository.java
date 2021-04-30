package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.Token;

public interface TokenRepository extends JpaRepository<Token, Long> {
    Optional<Token> findByValue(String value);

}
