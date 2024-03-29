package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.PendingRegistration;

public interface PendingRegistrationsRepository extends JpaRepository<PendingRegistration, Long> {
    Optional<PendingRegistration> findByActivationCode(String activationCode);

    boolean existsByEmailAddress(String emailAddress);

    boolean existsByActivationCode(String activationCode);

    int deleteByCreatedAtLessThan(LocalDateTime date);

    default int deletePendingRegistrationsOlderThanDays(long olderThanDays) {
        return deleteByCreatedAtLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }
}
