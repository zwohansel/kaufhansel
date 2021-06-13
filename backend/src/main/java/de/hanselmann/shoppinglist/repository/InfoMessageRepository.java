package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.InfoMessage;

public interface InfoMessageRepository extends JpaRepository<InfoMessage, Long> {
    List<InfoMessage> findByValidFromLessThanAndValidToGreaterThan(LocalDateTime dateA, LocalDateTime dateB);

    default List<InfoMessage> findValidMessages() {
        return findByValidFromLessThanAndValidToGreaterThan(LocalDateTime.now(), LocalDateTime.now());
    }
}
