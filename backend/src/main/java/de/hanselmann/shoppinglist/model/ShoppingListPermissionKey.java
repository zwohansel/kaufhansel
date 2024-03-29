package de.hanselmann.shoppinglist.model;

import java.io.Serializable;
import java.util.Objects;

import javax.persistence.Column;
import javax.persistence.Embeddable;

@Embeddable
public class ShoppingListPermissionKey implements Serializable {
    private static final long serialVersionUID = -1961771194001336087L;

    @Column(name = "LIST_ID")
    private Long shoppingListId;

    @Column(name = "USER_ID")
    private Long shoppingListUserId;

    protected ShoppingListPermissionKey() {

    }

    public ShoppingListPermissionKey(Long shoppingListId, Long shoppingListUserId) {
        this.shoppingListId = shoppingListId;
        this.shoppingListUserId = shoppingListUserId;
    }

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
