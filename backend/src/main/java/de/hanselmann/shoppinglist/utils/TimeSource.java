package de.hanselmann.shoppinglist.utils;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;

@Component
public class TimeSource {

    public LocalDateTime dateTimeNow() {
        return LocalDateTime.now();
    }
}
