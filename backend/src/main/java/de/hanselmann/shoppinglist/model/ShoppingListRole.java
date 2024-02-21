package de.hanselmann.shoppinglist.model;

public enum ShoppingListRole {
    ADMIN, // Chefhansel add+delete items, check+unchek items, set category, user
           // management, last admin can delete list
    READ_WRITE, // Schreibhansel: add+delete items, check+unchek items, set category
    CHECK_ONLY, // Kaufhansel: check+unchek items
    READ_ONLY;// Guckhansel: read-only

    public boolean canEditList() {
        return this == ADMIN;
    }

    public boolean canEditItems() {
        return this == ADMIN || this == READ_WRITE;
    }

    public boolean canCheckItems() {
        return this == ADMIN || this == READ_WRITE || this == CHECK_ONLY;
    }

    public boolean canDeleteUsers() {
        return this == ADMIN;
    }
}
