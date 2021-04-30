package de.hanselmann.shoppinglist.restapi.dto;

public class MoveShoppingListItemDto {
    private long itemId;
    private int targetIndex;

    public long getItemId() {
        return itemId;
    }

    public void setItemId(long itemId) {
        this.itemId = itemId;
    }

    public int getTargetIndex() {
        return targetIndex;
    }

    public void setTargetIndex(int moveToIndex) {
        this.targetIndex = moveToIndex;
    }

}
