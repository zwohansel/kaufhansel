package de.hanselmann.shoppinglist.restapi.dto;

import java.util.List;

public class ShoppingListInfoDto {
    private final String id;
    private final String name;
    private final List<ShoppingListUserReferenceDto> users;

    public ShoppingListInfoDto(String id, String name, List<ShoppingListUserReferenceDto> users) {
        this.name = name;
        this.id = id;
        this.users = users;
    }

    public String getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<ShoppingListUserReferenceDto> getUsers() {
        return users;
    }
}
