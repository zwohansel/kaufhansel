package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class RegistrationDataDto {
    private String userName;
    private String inviteCode;
    private Optional<String> emailAddress;
    private String password;

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getInviteCode() {
        return inviteCode;
    }

    public void setInviteCode(String inviteCode) {
        this.inviteCode = inviteCode;
    }

    public Optional<String> getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(Optional<String> emailAddress) {
        this.emailAddress = emailAddress;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

}
