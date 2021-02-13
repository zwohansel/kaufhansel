package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

import de.hanselmann.shoppinglist.model.PendingRegistration;

public interface PendingRegistrationRepository extends MongoRepository<PendingRegistration, ObjectId> {
    Optional<PendingRegistration> findByActivationCode(String activationCode);

    boolean existsByEmailAddress(String emailAddress);

    boolean existsByActivationCode(String activationCode);

    int deleteByCreationDateLessThan(LocalDateTime date);

    default int deletePendingRegistrationsOlderThanDays(long olderThanDays) {
        return deleteByCreationDateLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }
}
