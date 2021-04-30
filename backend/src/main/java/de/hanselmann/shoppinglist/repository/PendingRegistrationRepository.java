package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.PendingRegistration;

public interface PendingRegistrationRepository extends JpaRepository<PendingRegistration, Long> {
    Optional<PendingRegistration> findByActivationCode(String activationCode);

    boolean existsByEmailAddress(String emailAddress);

    boolean existsByActivationCode(String activationCode);

    int deleteByCreationDateLessThan(LocalDateTime date);

    default int deletePendingRegistrationsOlderThanDays(long olderThanDays) {
        return deleteByCreationDateLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }
}
