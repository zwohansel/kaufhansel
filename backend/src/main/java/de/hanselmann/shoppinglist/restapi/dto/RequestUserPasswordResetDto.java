package de.hanselmann.shoppinglist.restapi.dto;

public class RequestUserPasswordResetDto {
    private String emailAddress;

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String emailAddress) {
        this.emailAddress = emailAddress;
    }

}
