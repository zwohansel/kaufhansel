package de.hanselmann.shoppinglist.restapi.dto;

public class SendListInviteDto {
    private String emailAddress;
    private String shoppingListId;

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    public Long getShoppingListId() {
        return Long.valueOf(shoppingListId);
    }

    public void setShoppingListId(Long shoppingListId) {
        this.shoppingListId = Long.toString(shoppingListId);
    }

}
