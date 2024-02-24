package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListPermissionsUpdateDto {
    String userId;
    ShoppingListRole role;

    public long getUserId() {
        return Long.valueOf(userId);
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public ShoppingListRole getRole() {
        return role;
    }

    public void setRole(ShoppingListRole role) {
        this.role = role;
    }

}
