package de.hanselmann.shoppinglist.configuration;

import org.springframework.boot.task.TaskSchedulerBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

@Configuration
@EnableScheduling
public class SchedulingConfiguration {

    /*
     * Scheduled Tasks do not work out of the box with web sockets enabled (see
     * ShoppingListWebSocketConfig). We need to manually create a
     * ThreadPoolTaskScheduler.
     * https://stackoverflow.com/questions/56169448/scheduled-task-not-working-with-
     * websockets
     */
    @Bean
    public ThreadPoolTaskScheduler taskScheduler(TaskSchedulerBuilder builder) {
        return builder.build();
    }

}
