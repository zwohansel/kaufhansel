package de.hanselmann.shoppinglist.configuration;

import com.mongodb.ConnectionString;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.mongo.MongoProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.config.AbstractMongoClientConfiguration;
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories;

@Configuration
@EnableMongoRepositories(basePackages = "de.hanselmann.shoppinglist.repository")
public class MongoDBConfiguration extends AbstractMongoClientConfiguration {

    private final MongoProperties properties;

    @Autowired
    public MongoDBConfiguration(MongoProperties properties) {
        this.properties = properties;
    }

    @Bean
    public MongoTransactionManager transactionManager(MongoDatabaseFactory dbFactory) {
        return new MongoTransactionManager(dbFactory);
    }

    @Override
    public MongoClient mongoClient() {
        ConnectionString connection = new ConnectionString(properties.getUri());
        return MongoClients.create(connection);
    }

    @Override
    protected String getDatabaseName() {
        return properties.getDatabase();
    }
}
