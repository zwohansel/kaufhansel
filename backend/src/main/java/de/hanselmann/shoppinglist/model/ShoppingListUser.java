package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

@Entity
@Table(name = "USERS")
public class ShoppingListUser {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "SUPERUSER", nullable = false)
    private boolean superUser = false;

    @Column(name = "EMAIL", nullable = false, unique = true)
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

    @OneToMany(mappedBy = "user")
    private List<ShoppingListPermission> shoppingLists = new ArrayList<>();

    @OneToMany(mappedBy = "user", cascade = CascadeType.REMOVE)
    private List<Token> tokens = new ArrayList<>();

    @OneToMany(mappedBy = "invitedBy", cascade = CascadeType.REMOVE)
    private List<ListInvite> createdInvites = new ArrayList<>();

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

    public Long getId() {
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

    public List<ShoppingListPermission> getShoppingListPermissions() {
        return Collections.unmodifiableList(shoppingLists);
    }

    // TODO: Not the owning side!
    public void addShoppingList(ShoppingListPermission shoppingListReference) {
        shoppingLists.add(shoppingListReference);
    }

    // TODO: Not the owning side!
    public void deleteShoppingList(ShoppingListPermission shoppingListReference) {
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
