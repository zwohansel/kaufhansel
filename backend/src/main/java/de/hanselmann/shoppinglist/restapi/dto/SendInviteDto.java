package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class SendInviteDto {
    private String emailAddress;
    private Optional<Long> shoppingListId;

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    public Optional<Long> getShoppingListId() {
        return shoppingListId;
    }

    public void setShoppingListId(Optional<Long> shoppingListId) {
        this.shoppingListId = shoppingListId;
    }

}
