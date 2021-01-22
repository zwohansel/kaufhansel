package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserReferenceDto {
    final String userId;
    final String userName;

    public ShoppingListUserReferenceDto(String userId, String userName) {
        this.userId = userId;
        this.userName = userName;
    }

    public String getUserId() {
        return userId;
    }

    public String getUserName() {
        return userName;
    }

}
