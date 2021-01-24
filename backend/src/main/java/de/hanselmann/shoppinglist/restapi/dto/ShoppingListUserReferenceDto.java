package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserReferenceDto {
    final String userId;
    final String userName;
    final String userEmailAddress;
    final ShoppingListPermissionsDto permissions;

    public ShoppingListUserReferenceDto(String userId, String userName, String userEmailAddress,
            ShoppingListPermissionsDto permissions) {
        this.userId = userId;
        this.userName = userName;
        this.userEmailAddress = userEmailAddress;
        this.permissions = permissions;
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

    public ShoppingListPermissionsDto getPermissions() {
        return permissions;
    }

}
