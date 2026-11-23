package de.hanselmann.shoppinglist.restapi.dto;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

public class RegistrationResultDto {
    public enum Status {
        SUCCESS,
        EMAIL_INVALID,
        PASSWORD_INVALID,
        FAILURE
    }

    public static RegistrationResultDto success() {
        return new RegistrationResultDto(Status.SUCCESS);
    }

    public static RegistrationResultDto emailInvalid() {
        return new RegistrationResultDto(Status.EMAIL_INVALID);
    }

    public static RegistrationResultDto passwordInvalid() {
        return new RegistrationResultDto(Status.PASSWORD_INVALID);
    }

    public static RegistrationResultDto fail() {
        return new RegistrationResultDto(Status.FAILURE);
    }

    private final Status status;

    @JsonCreator
    private RegistrationResultDto(@JsonProperty("status") Status status) {
        this.status = status;
    }

    public Status getStatus() {
        return status;
    }
}
