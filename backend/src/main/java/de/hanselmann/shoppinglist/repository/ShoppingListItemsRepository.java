package de.hanselmann.shoppinglist.repository;

import java.util.stream.Stream;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingListCategory;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    void deleteByListId(long listId);

    void deleteByListIdAndChecked(long listId, boolean checked);

    void deleteByListIdAndCheckedAndCategory(long listId, boolean checked, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByListIdAndCategory(long listId, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByListId(long listId);

}
