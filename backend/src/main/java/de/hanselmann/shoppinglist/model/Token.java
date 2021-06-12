package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

@Entity
@Table(name = "TOKENS")
public class Token {
    @Id
    private long id;

    @Column(name = "VALUE", nullable = false)
    private String value;

    @Column(name = "EXPIRES_AT", nullable = false)
    private LocalDateTime expirationDate;

    @ManyToOne
    @JoinColumn(name = "USER_ID", nullable = false)
    private ShoppingListUser user;

    public Token() {

    }

    public Token(String value, ShoppingListUser user, LocalDateTime expirationDate) {
        this.value = value;
        this.user = user;
        this.expirationDate = expirationDate;
    }

    public long getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public ShoppingListUser getUser() {
        return user;
    }

    public LocalDateTime getExpirationDate() {
        return expirationDate;
    }

}
