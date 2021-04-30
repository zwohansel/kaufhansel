package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListUserReferenceDto {
    final long userId;
    final String userName;
    final String userEmailAddress;
    final ShoppingListRole userRole;

    public ShoppingListUserReferenceDto(long userId, String userName, String userEmailAddress,
            ShoppingListRole userRole) {
        this.userId = userId;
        this.userName = userName;
        this.userEmailAddress = userEmailAddress;
        this.userRole = userRole;
    }

    public long getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

    public String getUserEmailAddress() {
        return userEmailAddress;
    }

    public ShoppingListRole getuserRole() {
        return userRole;
    }

}
