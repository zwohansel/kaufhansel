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

    public static Invite create(String code, ShoppingListUser invitor) {
        return new Invite(code, invitor.getId(), LocalDateTime.now());
    }

    public Invite() {
    }

    private Invite(String code, ObjectId generatedByUserId, LocalDateTime generatedAt) {
        this.code = code;
        this.generatedByUser = generatedByUserId;
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
