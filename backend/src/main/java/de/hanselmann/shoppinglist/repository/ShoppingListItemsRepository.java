package de.hanselmann.shoppinglist.repository;

import de.hanselmann.shoppinglist.model.ShoppingListCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.stream.Stream;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    void deleteByList(ShoppingList list);

    void deleteByListAndChecked(ShoppingList list, boolean checked);

    void deleteByListAndCheckedAndCategory(ShoppingList list, boolean checked, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByListAndCategory(ShoppingList list, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByList(ShoppingList list);

    // TODO: If this works do not take ShoppingList parameter in other methods
    void deleteByListAndId(long listId, long itemId);

}
