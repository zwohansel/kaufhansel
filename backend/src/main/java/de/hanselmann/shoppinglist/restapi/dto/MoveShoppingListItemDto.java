package de.hanselmann.shoppinglist.restapi.dto;

public class MoveShoppingListItemDto {
    private String itemId;
    private int targetIndex;

    public long getItemId() {
        return Long.valueOf(itemId);
    }

    public void setItemId(long itemId) {
        this.itemId = Long.toString(itemId);
    }

    public int getTargetIndex() {
        return targetIndex;
    }

    public void setTargetIndex(int moveToIndex) {
        this.targetIndex = moveToIndex;
    }

}
