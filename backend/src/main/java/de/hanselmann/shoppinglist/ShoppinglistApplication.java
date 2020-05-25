package de.hanselmann.shoppinglist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

import de.hanselmann.shoppinglist.configuration.ShoppingListProperties;

@EnableMongoRepositories
@EnableConfigurationProperties(ShoppingListProperties.class)
@SpringBootApplication
public class ShoppinglistApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShoppinglistApplication.class, args);
    }

}
