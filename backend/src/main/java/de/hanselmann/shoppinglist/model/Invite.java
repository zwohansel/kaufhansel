package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class Invite {
    @Id
    private ObjectId id;
    private String code;
    private ObjectId generatedByUser;
    private LocalDateTime generatedAt;

    public Invite() {
    }

    public Invite(String code, ShoppingListUser generatedByUser, LocalDateTime generatedAt) {
        this.code = code;
        this.generatedByUser = generatedByUser.getId();
        this.generatedAt = generatedAt;
    }

    public ObjectId getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public ObjectId getGeneratedByUser() {
        return generatedByUser;
    }

    public LocalDateTime getGeneratedAt() {
        return generatedAt;
    }

}
