package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ListInvite;
import de.hanselmann.shoppinglist.model.ShoppingListUser;

public interface ListInviteRepository extends JpaRepository<ListInvite, Long> {
    boolean existsByInviteeEmailAddress(String emailAddress);

    int deleteByCreatedAtLessThan(LocalDateTime date);

    default int deleteInvitesOlderThanDays(long olderThanDays) {
        return deleteByCreatedAtLessThan(LocalDateTime.now().minusDays(olderThanDays));
    }

    int deleteByInvitedByUser(ShoppingListUser user);

    List<ListInvite> findByInviteeEmailAddress(String emailAddress);
}
