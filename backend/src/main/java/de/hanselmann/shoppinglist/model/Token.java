package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "TOKENS")
public class Token {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "VALUE", nullable = false)
    private String value;

    @Enumerated(EnumType.STRING)
    @Column(name = "TYPE", nullable = false)
    private TokenType type;

    @Column(name = "EXPIRES_AT", nullable = false)
    private LocalDateTime expirationDate;

    @ManyToOne
    @JoinColumn(name = "USER_ID", nullable = false)
    private ShoppingListUser user;

    public Token() {

    }

    public Token(String value, TokenType type, ShoppingListUser user, LocalDateTime expirationDate) {
        this.value = value;
        this.type = type;
        this.user = user;
        this.expirationDate = expirationDate;
    }

    public Long getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public TokenType getType() {
        return type;
    }

    public ShoppingListUser getUser() {
        return user;
    }

    public LocalDateTime getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(LocalDateTime expirationDate) {
        this.expirationDate = expirationDate;
    }

    public boolean isExpired(LocalDateTime now) {
        return !now.isBefore(expirationDate);
    }

}
