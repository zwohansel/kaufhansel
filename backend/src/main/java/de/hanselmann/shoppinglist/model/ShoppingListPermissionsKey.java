package de.hanselmann.shoppinglist.model;

import java.io.Serializable;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Embeddable;

@Embeddable
public class ShoppingListPermissionsKey implements Serializable {
    private static final long serialVersionUID = -1961771194001336087L;

    @Column(name = "LIST_ID")
    private long shoppingListId;

    @Column(name = "USER_ID")
    private long shoppingListUserId;

    public long getShoppingListId() {
        return shoppingListId;
    }

    public void setShoppingListId(long shoppingListId) {
        this.shoppingListId = shoppingListId;
    }

    public long getShoppingListUserId() {
        return shoppingListUserId;
    }

    public void setShoppingListUserId(long shoppingListUserId) {
        this.shoppingListUserId = shoppingListUserId;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof ShoppingListPermissionsKey) {
            ShoppingListPermissionsKey other = (ShoppingListPermissionsKey) obj;
            return shoppingListId == other.shoppingListId && shoppingListUserId == other.shoppingListUserId;
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(shoppingListId, shoppingListUserId);
    }

}
