package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserInfoDto {
    private final long id;
    private final String token;
    private final String username;
    private final String emailAddress;

    /**
     * Required to run the test in eclipse
     */
    protected ShoppingListUserInfoDto() {
        this(0, null, null, null);
    }

    public ShoppingListUserInfoDto(long id, String token, String username, String emailAddress) {
        this.id = id;
        this.token = token;
        this.username = username;
        this.emailAddress = emailAddress;
    }

    public long getId() {
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
