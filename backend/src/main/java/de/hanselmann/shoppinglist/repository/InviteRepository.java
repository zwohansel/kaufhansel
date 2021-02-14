package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.Invite;

public interface InviteRepository extends MongoRepository<Invite, ObjectId> {
    Optional<Invite> findByCode(String code);

    boolean existsByCode(String code);

    boolean existsByInviteeEmailAddress(String emailAddress);

    int deleteByGeneratedAtLessThan(LocalDateTime date);

    default int deleteInvitesOlderThanDays(long olderThanDays) {
        return deleteByGeneratedAtLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }

    int deleteByGeneratedByUser(ObjectId userId);
}
