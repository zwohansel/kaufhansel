package de.hanselmann.shoppinglist.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
import de.hanselmann.shoppinglist.model.ShoppingListPermissionKey;

public interface ShoppingListPermissionsRepository
        extends JpaRepository<ShoppingListPermission, ShoppingListPermissionKey> {

    Optional<ShoppingListPermission> findByList(ShoppingList list);

}
