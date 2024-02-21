package de.hanselmann.shoppinglist.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import de.hanselmann.shoppinglist.service.DefaultTimeService;
import de.hanselmann.shoppinglist.service.TimeService;

@Configuration
public class TimeServiceConfiguration {

    @Bean
    public TimeService getTimeService() {
        return new DefaultTimeService();
    }

}
