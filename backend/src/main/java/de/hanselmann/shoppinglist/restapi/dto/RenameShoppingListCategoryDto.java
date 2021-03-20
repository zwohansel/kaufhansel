package de.hanselmann.shoppinglist.restapi.dto;

public class RenameShoppingListCategoryDto {
    private String oldCategory;
    private String newCategory;

    public String getOldCategory() {
        return oldCategory;
    }

    public void setOldCategory(String oldCategory) {
        this.oldCategory = oldCategory;
    }

    public String getNewCategory() {
        return newCategory;
    }

    public void setNewCategory(String newCategory) {
        this.newCategory = newCategory;
    }
}
