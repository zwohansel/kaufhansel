package de.hanselmann.shoppinglist.restapi.dto;

public class RegistrationResultDto {
    private enum Status {
        SUCCESS,
        EMAIL_INVALID,
        INVITE_CODE_INVALID,
        PASSWORD_INVALID,
        FAILURE
    }

    public static RegistrationResultDto success() {
        return new RegistrationResultDto(Status.SUCCESS);
    }

    public static RegistrationResultDto emailInvalid() {
        return new RegistrationResultDto(Status.EMAIL_INVALID);
    }

    public static RegistrationResultDto inviteCodeInvalid() {
        return new RegistrationResultDto(Status.INVITE_CODE_INVALID);
    }

    public static RegistrationResultDto passwordInvalid() {
        return new RegistrationResultDto(Status.PASSWORD_INVALID);
    }

    public static RegistrationResultDto fail() {
        return new RegistrationResultDto(Status.FAILURE);
    }

    private final Status status;

    private RegistrationResultDto(Status status) {
        this.status = status;
    }

    public Status getStatus() {
        return status;
    }
}
