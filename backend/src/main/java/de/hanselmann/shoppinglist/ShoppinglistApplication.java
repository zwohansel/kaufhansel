package de.hanselmann.shoppinglist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import de.hanselmann.shoppinglist.configuration.ShoppingListProperties;

@EnableConfigurationProperties(ShoppingListProperties.class)
@SpringBootApplication
public class ShoppinglistApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShoppinglistApplication.class, args);
    }

}
