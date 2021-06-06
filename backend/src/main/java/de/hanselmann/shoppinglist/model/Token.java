package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
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

    public Token() {

    }

    public Token(String value, LocalDateTime expirationDate) {
        this.value = value;
        this.expirationDate = expirationDate;
    }

    public long getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public LocalDateTime getExpirationDate() {
        return expirationDate;
    }

}
