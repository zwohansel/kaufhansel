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
        this("", null, null, null);
    }

    public ShoppingListUserReferenceDto(String userId, String userName, String userEmailAddress,
            ShoppingListRole userRole) {
        this.userId = userId;
        this.userName = userName;
        this.userEmailAddress = userEmailAddress;
        this.userRole = userRole;
    }

    public String getUserId() {
        return userId;
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
