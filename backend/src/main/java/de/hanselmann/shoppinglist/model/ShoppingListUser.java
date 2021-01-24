package de.hanselmann.shoppinglist.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class ShoppingListUser {
    @Id
    private ObjectId id;
    private String username;
    private String password;
    private String emailAddress;
    private List<ShoppingListReference> shoppingLists = new ArrayList<>();

    public ObjectId getId() {
        return id;
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

    public String getEmailAddress() {
        return emailAddress;
    }

    public void setEmailAddress(String email) {
        this.emailAddress = email;
    }

    public List<ShoppingListReference> getShoppingLists() {
        return Collections.unmodifiableList(shoppingLists);
    }

    public void addShoppingList(ShoppingListReference shoppingListReference) {
        shoppingLists.add(shoppingListReference);
    }

    public void deleteShoppingList(ObjectId shoppingListId) {
        if (!shoppingLists.removeIf(ref -> ref.getShoppingListId().equals(shoppingListId))) {
            throw new NoSuchElementException();
        }
    }

}
