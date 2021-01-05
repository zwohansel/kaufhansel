package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListInfoDto {
    private final String name;
    private final String id;

    public ShoppingListInfoDto(String name, String id) {
        this.name = name;
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public String getId() {
        return id;
    }
}
