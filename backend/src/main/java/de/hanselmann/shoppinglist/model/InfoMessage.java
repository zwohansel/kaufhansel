package de.hanselmann.shoppinglist.model;

import java.time.LocalDateTime;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

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

    public Long getId() {
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

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public void setSeverity(Severity severity) {
        this.severity = severity;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setDismissLabel(String dismissLabel) {
        this.dismissLabel = dismissLabel;
    }

    public void setValidFrom(LocalDateTime validFrom) {
        this.validFrom = validFrom;
    }

    public void setValidTo(LocalDateTime validTo) {
        this.validTo = validTo;
    }

    @Override
    public String toString() {
        return "InfoMessage [id=" + id + ", enabled=" + enabled + ", severity=" + severity + ", message=" + message
                + ", dismissLabel=" + dismissLabel + ", validFrom=" + validFrom + ", validTo=" + validTo + "]";
    }

}
