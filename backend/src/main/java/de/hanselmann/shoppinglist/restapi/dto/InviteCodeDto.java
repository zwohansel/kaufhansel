package de.hanselmann.shoppinglist.restapi.dto;

public class InviteCodeDto {
    private final String code;

    public InviteCodeDto(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    };

}
