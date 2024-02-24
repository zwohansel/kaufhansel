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
        this(0, null, false, null);
    }

    public ShoppingListItemDto(long id, String name, boolean checked, String category) {
        this.id = Long.toString(id);
        this.name = name;
        this.checked = checked;
        this.category = category;
    }

    public long getId() {
        return Long.valueOf(id);
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
