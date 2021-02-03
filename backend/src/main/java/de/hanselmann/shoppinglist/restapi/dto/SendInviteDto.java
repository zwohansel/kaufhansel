package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class SendInviteDto {
    private String emailAddress;
    private Optional<String> shoppingListId;

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    public Optional<String> getShoppingListId() {
        return shoppingListId;
    }

    public void setShoppingListId(Optional<String> shoppingListId) {
        this.shoppingListId = shoppingListId;
    }

}
