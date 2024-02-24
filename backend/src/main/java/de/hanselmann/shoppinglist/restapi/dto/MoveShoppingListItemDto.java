package de.hanselmann.shoppinglist.restapi.dto;

public class MoveShoppingListItemDto {
    private String itemId;
    private int targetIndex;

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public int getTargetIndex() {
        return targetIndex;
    }

    public void setTargetIndex(int moveToIndex) {
        this.targetIndex = moveToIndex;
    }

}
