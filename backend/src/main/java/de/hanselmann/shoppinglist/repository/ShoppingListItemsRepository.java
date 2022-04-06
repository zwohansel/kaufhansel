package de.hanselmann.shoppinglist.repository;

import java.util.stream.Stream;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListCategory;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    void deleteByList(ShoppingList list);

    void deleteByListAndChecked(ShoppingList list, boolean checked);

    void deleteByListAndCheckedAndCategory(ShoppingList list, boolean checked, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByListAndCategory(ShoppingList list, ShoppingListCategory ofCategory);

    Stream<ShoppingListItem> findByList(ShoppingList list);

}
