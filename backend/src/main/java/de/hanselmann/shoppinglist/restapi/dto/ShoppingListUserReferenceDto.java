package de.hanselmann.shoppinglist.restapi.dto;

import de.hanselmann.shoppinglist.model.ShoppingListRole;

public class ShoppingListUserReferenceDto {
    final String userId;
    final String userName;
    final String userEmailAddress;
    final ShoppingListRole userRole;

    /**
     * Required to run the test in eclipse
     */
    protected ShoppingListUserReferenceDto() {
        this(0, null, null, null);
    }

    public ShoppingListUserReferenceDto(long userId, String userName, String userEmailAddress,
            ShoppingListRole userRole) {
        this.userId = Long.toString(userId);
        this.userName = userName;
        this.userEmailAddress = userEmailAddress;
        this.userRole = userRole;
    }

    public long getUserId() {
        return Long.valueOf(userId);
    }

    public String getUserName() {
        return userName;
    }

    public String getUserEmailAddress() {
        return userEmailAddress;
    }

    public ShoppingListRole getUserRole() {
        return userRole;
    }

}
