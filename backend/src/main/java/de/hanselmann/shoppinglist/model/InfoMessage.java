package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Entity;

import org.springframework.data.annotation.Id;

@Entity
public class InfoMessage {
    public enum Severity {
        CRITICAL,
        INFO
    }

    @Id
    private long id;
    private boolean enabled;
    private int messageNumber;
    private Severity severity;
    private String message;
    private String dismissLabel;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;

    public long getId() {
        return id;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public int getMessageNumber() {
        return messageNumber;
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
