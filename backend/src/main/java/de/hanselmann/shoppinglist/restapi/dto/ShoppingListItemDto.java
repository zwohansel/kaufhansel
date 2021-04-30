package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListItemDto {
    private final long id;
    private final String name;
    private final boolean checked;
    private final String category;

    public ShoppingListItemDto(long id, String name, boolean checked, String category) {
        this.id = id;
        this.name = name;
        this.checked = checked;
        this.category = category;
    }

    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public boolean isChecked() {
        return checked;
    }

    public String getCategory() {
        return category;
    }

}
