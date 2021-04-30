package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class Token {
    @Id
    private long id;
    private String value;
    private long userId; // TODO: userId oder user?
    private LocalDateTime expirationDate;

    public Token() {

    }

    public Token(String value, long userId, LocalDateTime expirationDate) {
        this.value = value;
        this.userId = userId;
        this.expirationDate = expirationDate;
    }

    public long getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public long getUserId() {
        return userId;
    }

    public LocalDateTime getExpirationDate() {
        return expirationDate;
    }

}
