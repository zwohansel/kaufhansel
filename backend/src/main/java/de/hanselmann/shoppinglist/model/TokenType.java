package de.hanselmann.shoppinglist.model;

public enum TokenType {
    /**
     * Authenticates the requests of a user.
     */
    ACCESS,

    /**
     * Entitles its owner to obtain a new access token without the user having to log in again.
     */
    REFRESH
}
