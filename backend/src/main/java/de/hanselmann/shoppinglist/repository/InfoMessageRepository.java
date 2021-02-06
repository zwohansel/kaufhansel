package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.InfoMessage;

public interface InfoMessageRepository extends MongoRepository<InfoMessage, ObjectId> {
    Stream<InfoMessage> findByValidFromLessThanAndValidToGreaterThan(LocalDateTime dateA, LocalDateTime dateB);

    default Stream<InfoMessage> findValidMessages() {
        return findByValidFromLessThanAndValidToGreaterThan(LocalDateTime.now(), LocalDateTime.now());
    }
}
