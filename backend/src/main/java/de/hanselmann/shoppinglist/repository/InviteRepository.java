package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.Invite;

public interface InviteRepository extends MongoRepository<Invite, ObjectId> {
    Optional<Invite> findByCode(String code);

    boolean existsByCode(String code);
}
