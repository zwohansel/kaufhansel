package de.hanselmann.shoppinglist.restapi.dto;

public class ShoppingListStatusDto {

    private Integer numberOfOpenItems;

    public ShoppingListStatusDto(Integer numberOfOpenItems) {
        this.numberOfOpenItems = numberOfOpenItems;
    }

    public Integer getNumberOfOpenItems() {
        return numberOfOpenItems;
    }

    public void setNumberOfOpenItems(Integer numberOfOpenItems) {
        this.numberOfOpenItems = numberOfOpenItems;
    }

}
