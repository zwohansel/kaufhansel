package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class RemoveShoppingListCategoryDto {
    private Optional<String> category;

    public Optional<String> getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = Optional.ofNullable(category);
    }

    public void setCategory(Optional<String> category) {
        this.category = category;
    }
}
