package de.hanselmann.shoppinglist;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@EnableMongoRepositories
@SpringBootApplication
public class ShoppinglistApplication {

	public static void main(String[] args) {
		SpringApplication.run(ShoppinglistApplication.class, args);
	}

}
