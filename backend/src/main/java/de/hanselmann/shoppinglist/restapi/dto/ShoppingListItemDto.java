package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListItemDto {
    private String id;
    private final String name;
    private final boolean checked;
    private final String category;

    /**
     * Required to run the test in eclipse
     */
    protected ShoppingListItemDto() {
        this("", null, false, null);
    }

    public ShoppingListItemDto(String id, String name, boolean checked, String category) {
        this.id = id;
        this.name = name;
        this.checked = checked;
        this.category = category;
    }

    public String getId() {
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

    @Override
    public String toString() {
        return "ShoppingListItemDto{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", checked=" + checked +
                ", category='" + category + '\'' +
                '}';
    }
}
