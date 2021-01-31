package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListPermissionsDto {
    final ShoppingListRole role;

    public ShoppingListPermissionsDto(ShoppingListRole role) {
        this.role = role;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public boolean isCanEditList() {
        return role.canEditList();
    }

    public boolean isCanEditItems() {
        return role.canEditItems();
    }

    public boolean isCanCheckItems() {
        return role.canCheckItems();
    }
}
