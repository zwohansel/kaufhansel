package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class ShoppingListUser {
    @Id
    private long id;
    private boolean superUser = false;
    private String username;
    private String password;
    private String emailAddress;
    private LocalDateTime registrationDate;
    private ShoppingListUser invitedBy;
    private List<ShoppingListReference> shoppingLists = new ArrayList<>();
    private String passwordResetCode;
    private LocalDateTime passwordResetRequestedAt;

    public static ShoppingListUser create(PendingRegistration pendingRegistration) {
        if (pendingRegistration.isExpired()) {
            throw new IllegalArgumentException("Pending registration is expired");
        }
        ShoppingListUser user = new ShoppingListUser();
        user.emailAddress = pendingRegistration.getEmailAddress().toLowerCase().strip();
        user.username = pendingRegistration.getUserName();
        user.password = pendingRegistration.getPassword();
        user.invitedBy = pendingRegistration.getInvitedBy();
        user.registrationDate = LocalDateTime.now();
        return user;
    }

    private ShoppingListUser() {
    }

    ShoppingListUser(long id, boolean superUser, String username, String password, String emailAddress,
            LocalDateTime registrationDate, ShoppingListUser invitedBy, List<ShoppingListReference> shoppingLists,
            String passwordResetCode, LocalDateTime passwordResetRequestedAt) {
        this.id = id;
        this.superUser = superUser;
        this.username = username;
        this.password = password;
        this.emailAddress = emailAddress;
        this.registrationDate = registrationDate;
        this.invitedBy = invitedBy;
        this.shoppingLists = shoppingLists;
        this.passwordResetCode = passwordResetCode;
        this.passwordResetRequestedAt = passwordResetRequestedAt;
    }

    public long getId() {
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

    public ShoppingListUser getInvitedBy() {
        return invitedBy;
    }

    public List<ShoppingListReference> getShoppingLists() {
        return Collections.unmodifiableList(shoppingLists);
    }

    public void addShoppingList(ShoppingListReference shoppingListReference) {
        shoppingLists.add(shoppingListReference);
    }

    public void deleteShoppingList(long shoppingListId) {
        if (!shoppingLists.removeIf(ref -> ref.getShoppingListId() == shoppingListId)) {
            throw new NoSuchElementException();
        }
    }

    public void setPasswordResetCode(String code, LocalDateTime requestedAt) {
        passwordResetCode = code;
        passwordResetRequestedAt = requestedAt;
    }

    public Optional<String> getPasswordResetCode() {
        return Optional.ofNullable(passwordResetCode);
    }

    public Optional<LocalDateTime> getPasswordResetRequestedAt() {
        return Optional.ofNullable(passwordResetRequestedAt);
    }

    public void clearPasswordResetCode() {
        passwordResetCode = null;
        passwordResetRequestedAt = null;
    }

    public boolean isSuperUser() {
        return superUser;
    }

}
