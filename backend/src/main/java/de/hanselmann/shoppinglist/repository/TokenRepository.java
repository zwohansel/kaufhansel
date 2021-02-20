package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.Token;

public interface TokenRepository extends MongoRepository<Token, ObjectId> {
    Optional<Token> findByValue(String value);

}
