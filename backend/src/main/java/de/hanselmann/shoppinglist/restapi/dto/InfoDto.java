package de.hanselmann.shoppinglist.restapi.dto;

import java.util.Optional;

public class InfoDto {

    public enum SeverityDto {
        CRITICAL,
        INFO
    }

    public static class InfoMessageDto {
        private final long messageNumber;
        private final SeverityDto severity;
        private final String message;
        private final String dismissLabel;

        public InfoMessageDto(long messageNumber, SeverityDto severity, String message, String dismissLabel) {
            this.messageNumber = messageNumber;
            this.severity = severity;
            this.message = message;
            this.dismissLabel = dismissLabel;
        }

        public long getMessageNumber() {
            return messageNumber;
        }

        public SeverityDto getSeverity() {
            return severity;
        }

        public String getMessage() {
            return message;
        }

        public String getDismissLabel() {
            return dismissLabel;
        }
    }

    private final String apiVersion;
    private final Optional<InfoMessageDto> message;

    public static InfoDto create(String apiVersion, Optional<InfoMessageDto> message) {
        return new InfoDto(apiVersion, message);
    }

    private InfoDto(String apiVersion, Optional<InfoMessageDto> message) {
        this.apiVersion = apiVersion;
        this.message = message;
    }

    public String getApiVersion() {
        return apiVersion;
    }

    public Optional<InfoMessageDto> getMessage() {
        return message;
    }
}
