package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserInfoDto {
    private final String id;
    private final String token;
    private final String username;
    private final String emailAddress;

    public ShoppingListUserInfoDto(String id, String token, String username, String emailAddress) {
        this.id = id;
        this.token = token;
        this.username = username;
        this.emailAddress = emailAddress;
    }

    public String getId() {
        return id;
    }

    public String getToken() {
        return token;
    }

    public String getUsername() {
        return username;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

}
