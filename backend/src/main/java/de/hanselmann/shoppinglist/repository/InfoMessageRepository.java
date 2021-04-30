package de.hanselmann.shoppinglist.repository;

import java.time.LocalDateTime;
import java.util.stream.Stream;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.InfoMessage;

public interface InfoMessageRepository extends JpaRepository<InfoMessage, Long> {
    Stream<InfoMessage> findByValidFromLessThanAndValidToGreaterThan(LocalDateTime dateA, LocalDateTime dateB);

    default Stream<InfoMessage> findValidMessages() {
        return findByValidFromLessThanAndValidToGreaterThan(LocalDateTime.now(), LocalDateTime.now());
    }
}
