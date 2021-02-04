package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
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
    private LocalDateTime registrationDate;
    private ObjectId invitedBy;
    private List<ShoppingListReference> shoppingLists = new ArrayList<>();

    public static ShoppingListUser create(PendingRegistration pendingRegistration) {
        if (pendingRegistration.isExpired()) {
            throw new IllegalArgumentException("Pending registration is expired");
        }
        ShoppingListUser user = new ShoppingListUser();
        user.emailAddress = pendingRegistration.getEmailAddress();
        user.username = pendingRegistration.getUserName();
        user.password = pendingRegistration.getPassword();
        user.invitedBy = pendingRegistration.getInvitedBy();
        user.registrationDate = LocalDateTime.now();
        return user;
    }

    public ObjectId getId() {
        return id;
    }

    public String getUsername() {
        return username;
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

    public LocalDateTime getRegistrationDate() {
        return registrationDate;
    }

    public ObjectId getInvitedBy() {
        return invitedBy;
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
