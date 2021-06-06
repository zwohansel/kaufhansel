package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "INFO_MESSAGES")
public class InfoMessage {
    public enum Severity {
        CRITICAL,
        INFO
    }

    @Id
    @Column(name = "ID", unique = true, nullable = false)
    private long id;

    @Column(name = "ENABLED", nullable = false)
    private boolean enabled;

    @Column(name = "SEVERITY", nullable = false)
    private Severity severity;

    @Column(name = "MESSAGE", nullable = false)
    private String message;

    @Column(name = "DISMISS_LABEL")
    private String dismissLabel;

    @Column(name = "VALID_FROM", nullable = false)
    private LocalDateTime validFrom;

    @Column(name = "VALID_TO", nullable = false)
    private LocalDateTime validTo;

    public long getId() {
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
