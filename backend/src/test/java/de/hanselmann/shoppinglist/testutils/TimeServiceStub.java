package de.hanselmann.shoppinglist.testutils;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import de.hanselmann.shoppinglist.service.TimeService;

public class TimeServiceStub implements TimeService {

    private LocalDateTime now;

    public TimeServiceStub() {
        reset();
    }

    public void reset() {
        now = LocalDateTime.ofEpochSecond(0, 0, ZoneOffset.UTC);
    }

    public void setNow(LocalDateTime now) {
        this.now = now;
    }

    @Override
    public LocalDateTime now() {
        return now;
    }

}
