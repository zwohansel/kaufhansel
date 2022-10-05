package de.hanselmann.shoppinglist.service;

import java.time.LocalDateTime;

public class DefaultTimeService implements TimeService {

    @Override
    public LocalDateTime now() {
        return LocalDateTime.now();
    }

}
