package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListCategory;

public interface ShoppingListCategoriesRepository extends JpaRepository<ShoppingListCategory, Long> {

    Optional<ShoppingListCategory> findByNameAndList(String name, ShoppingList list);

    void deleteByList(ShoppingList list);

    void deleteByNameAndList(String categoryName, ShoppingList list);

}
