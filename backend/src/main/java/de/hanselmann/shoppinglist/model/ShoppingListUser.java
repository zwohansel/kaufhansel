package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "USERS")
public class ShoppingListUser {
    @Id
    private long id;

    @Column(name = "SUPERUSER", nullable = false)
    private boolean superUser = false;

    @Column(name = "EMAIL", nullable = false)
    private String emailAddress;

    @Column(name = "NAME", nullable = false)
    private String username;

    @Column(name = "PASSWORD", nullable = false)
    private String password;

    @Column(name = "REGISTERED_AT", nullable = false)
    private LocalDateTime registeredAt;

    @Column(name = "PASSWORD_RESET_CODE")
    private String passwordResetCode;

    @Column(name = "PASSWORD_RESET_REQUESTED_AT")
    private LocalDateTime passwordResetRequestedAt;

    private List<ShoppingListPermissions> shoppingLists = new ArrayList<>();

    private List<Token> tokens = new ArrayList();

    public static ShoppingListUser create(PendingRegistration pendingRegistration) {
        if (pendingRegistration.isExpired()) {
            throw new IllegalArgumentException("Pending registration is expired");
        }
        var user = new ShoppingListUser();
        user.emailAddress = pendingRegistration.getEmailAddress().toLowerCase().strip();
        user.username = pendingRegistration.getUserName();
        user.password = pendingRegistration.getPassword();
        user.registeredAt = LocalDateTime.now();
        return user;
    }

    private ShoppingListUser() {
    }

    protected ShoppingListUser(long id, boolean superUser, String username, String password, String emailAddress,
            LocalDateTime registrationDate, List<ShoppingListPermissions> shoppingLists,
            String passwordResetCode, LocalDateTime passwordResetRequestedAt) {
        this.id = id;
        this.superUser = superUser;
        this.username = username;
        this.password = password;
        this.emailAddress = emailAddress;
        this.registeredAt = registrationDate;
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
        return registeredAt;
    }

    public List<ShoppingListPermissions> getShoppingLists() {
        return Collections.unmodifiableList(shoppingLists);
    }

    public void addShoppingList(ShoppingListPermissions shoppingListReference) {
        shoppingLists.add(shoppingListReference);
    }

    public void deleteShoppingList(ShoppingListPermissions shoppingListReference) {
        if (!shoppingLists.remove(shoppingListReference)) {
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
