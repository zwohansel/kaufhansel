package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.Invite;

public interface InviteRepository extends JpaRepository<Invite, Long> {
    Optional<Invite> findByCode(String code);

    boolean existsByCode(String code);

    boolean existsByInviteeEmailAddress(String emailAddress);

    int deleteByGeneratedAtLessThan(LocalDateTime date);

    default int deleteInvitesOlderThanDays(long olderThanDays) {
        return deleteByGeneratedAtLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }

    int deleteByGeneratedByUser(Long userId);
}
