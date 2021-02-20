package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class Token {
    @Id
    private ObjectId id;
    private String value;
    private ObjectId userId;
    private LocalDateTime expirationDate;

    public Token() {

    }

    public Token(String value, ObjectId userId, LocalDateTime expirationDate) {
        this.value = value;
        this.userId = userId;
        this.expirationDate = expirationDate;
    }

    public ObjectId getId() {
        return id;
    }

    public String getValue() {
        return value;
    }

    public ObjectId getUserId() {
        return userId;
    }

    public LocalDateTime getExpirationDate() {
        return expirationDate;
    }

}
