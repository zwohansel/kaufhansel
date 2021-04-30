package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListPermissionsUpdateDto {
    long userId;
    ShoppingListRole role;

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

}
