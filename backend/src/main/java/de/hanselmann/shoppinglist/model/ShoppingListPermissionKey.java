package de.hanselmann.shoppinglist.model;

import java.io.Serializable;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Embeddable;

@Embeddable
public class ShoppingListPermissionKey implements Serializable {
    private static final long serialVersionUID = -1961771194001336087L;

    @Column(name = "LIST_ID")
    private long shoppingListId;

    @Column(name = "USER_ID")
    private long shoppingListUserId;

    @Override
    public boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (obj instanceof ShoppingListPermissionKey) {
            ShoppingListPermissionKey other = (ShoppingListPermissionKey) obj;
            return shoppingListId == other.shoppingListId && shoppingListUserId == other.shoppingListUserId;
        }
        return false;
    }

    @Override
    public int hashCode() {
        return Objects.hash(shoppingListId, shoppingListUserId);
    }

}
