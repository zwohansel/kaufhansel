package de.hanselmann.shoppinglist.restapi.dto;

public class AddUserToShoppingListDto {
    String emailAddress;

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

    public String getEmailAddress() {
        return emailAddress;
    }
}
