package de.hanselmann.shoppinglist.model;

import org.springframework.data.annotation.Id;

public class ShoppingListUser {
    private String id;
    private String username;
    private String password;
    private String shoppingListId;

    @Id
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public boolean hasPassword() {
        return password != null && !password.isEmpty();
    }

    public String getShoppingListId() {
        return shoppingListId;
    }

}
