package de.hanselmann.shoppinglist.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;

public interface ShoppingListItemsRepository extends JpaRepository<ShoppingListItem, Long> {

    void deleteByList(ShoppingList list);

}
