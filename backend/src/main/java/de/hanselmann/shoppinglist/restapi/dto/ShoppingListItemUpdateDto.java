package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListItemUpdateDto {
    private String name;
    private boolean checked;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isChecked() {
        return checked;
    }

    public void setChecked(boolean checked) {
        this.checked = checked;
    }
}
