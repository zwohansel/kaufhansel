package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListCategory;

public interface ShoppingListCategoriesRepository extends JpaRepository<ShoppingListCategory, Long> {

    Optional<ShoppingListCategory> findByNameAndListId(String name, long listId);

    Optional<ShoppingListCategory> findByNameAndList(String name, ShoppingList list);

    void deleteByListId(long listId);

}
