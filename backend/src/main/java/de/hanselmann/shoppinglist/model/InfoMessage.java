package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;

public class InfoMessage {
    public enum Severity {
        CRITICAL,
        INFO
    }

    @Id
    private ObjectId id;
    private boolean enabled;
    private Severity severity;
    private String message;
    private String dismissLabel;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;

    public ObjectId getId() {
        return id;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public Severity getSeverity() {
        return severity;
    }

    public String getMessage() {
        return message;
    }

    public String getDismissLabel() {
        return dismissLabel;
    }

    public LocalDateTime getValidFrom() {
        return validFrom;
    }

    public LocalDateTime getValidTo() {
        return validTo;
    }
}
