package de.hanselmann.shoppinglist.repository;

import java.util.Optional;
import java.util.stream.Stream;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingListCategory;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    Optional<ShoppingListItem> findByIdAndListId(long itemId, long listId);

    void deleteByIdAndListId(long itemId, long listId);

    void deleteByListId(long listId);

    Stream<ShoppingListItem> findByListIdAndCategory(long listId, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByListId(long listId);

}
