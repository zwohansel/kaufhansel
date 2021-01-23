package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserReferenceDto {
    final String userId;
    final String userName;
    final String userEmailAddress;

    public ShoppingListUserReferenceDto(String userId, String userName, String userEmailAddress) {
        this.userId = userId;
        this.userName = userName;
        this.userEmailAddress = userEmailAddress;
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

}
