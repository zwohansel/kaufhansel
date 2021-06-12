package de.hanselmann.shoppinglist.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    void deleteByList(ShoppingList list);

    void deleteByListAndChecked(ShoppingList list, boolean checked);

    void deleteByListAndCheckedAndCategory(ShoppingList list, boolean checked, String ofCategory);

    // TODO: If this works do not take ShoppingList parameter in other methods
    void deleteByListAndId(long listId, long itemId);

}
