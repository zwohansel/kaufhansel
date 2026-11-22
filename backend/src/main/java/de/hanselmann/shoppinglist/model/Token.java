package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

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
