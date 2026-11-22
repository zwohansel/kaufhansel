package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListUserInfoDto {
    private final String id;
    private final String token;
    private final long tokenExpiresAt;
    private final String refreshToken;
    private final String username;
    private final String emailAddress;

    /**
     * Required to run the test in eclipse
     */
    protected ShoppingListUserInfoDto() {
        this("", null, 0, null, null, null);
    }

    public ShoppingListUserInfoDto(String id, String token, long tokenExpiresAt, String refreshToken, String username,
            String emailAddress) {
        this.id = id;
        this.token = token;
        this.tokenExpiresAt = tokenExpiresAt;
        this.refreshToken = refreshToken;
        this.username = username;
        this.emailAddress = emailAddress;
    }

    public String getId() {
        return id;
    }

    public String getToken() {
        return token;
    }

    /**
     * The point in time at which the token expires in seconds since the epoch.
     */
    public long getTokenExpiresAt() {
        return tokenExpiresAt;
    }

    /**
     * The token with which a new access token can be obtained once the current one
     * has expired. Only sent in response to a login.
     */
    public String getRefreshToken() {
        return refreshToken;
    }

    public String getUsername() {
        return username;
    }

    public String getEmailAddress() {
        return emailAddress;
    }

}
