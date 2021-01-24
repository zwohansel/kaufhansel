package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListPermissionsDto {
    final ShoppingListRole role;
    final boolean canEditList;
    final boolean canEditItems;
    final boolean canCheckItems;

    public ShoppingListPermissionsDto(ShoppingListRole role, boolean canEditList, boolean canEditItems,
            boolean canCheckItems) {
        this.role = role;
        this.canEditList = canEditList;
        this.canEditItems = canEditItems;
        this.canCheckItems = canCheckItems;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public boolean isCanEditList() {
        return canEditList;
    }

    public boolean isCanEditItems() {
        return canEditItems;
    }

    public boolean isCanCheckItems() {
        return canCheckItems;
    }
}
