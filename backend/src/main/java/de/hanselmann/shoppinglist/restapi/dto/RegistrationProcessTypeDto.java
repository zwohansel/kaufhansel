package de.hanselmann.shoppinglist.restapi.dto;

public class RegistrationProcessTypeDto {
    static private enum Type {
        INVALID,
        FULL_REGISTRATION,
        WITHOUT_EMAIL
    }

    public static RegistrationProcessTypeDto inviteInvalid() {
        return new RegistrationProcessTypeDto(Type.INVALID);
    }

    public static RegistrationProcessTypeDto fullRegistration() {
        return new RegistrationProcessTypeDto(Type.FULL_REGISTRATION);
    }

    public static RegistrationProcessTypeDto withoutEmail() {
        return new RegistrationProcessTypeDto(Type.WITHOUT_EMAIL);
    }

    private final Type type;

    private RegistrationProcessTypeDto(Type type) {
        this.type = type;
    }

    public Type getType() {
        return type;
    }

}
