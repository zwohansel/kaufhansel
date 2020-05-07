package de.hanselmann.shoppinglist.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import graphql.GraphQL;
import graphql.execution.AsyncExecutionStrategy;
import graphql.execution.AsyncSerialExecutionStrategy;
import graphql.schema.GraphQLSchema;

@Configuration
public class GraphQLConfiguration {

    @Bean
    public GraphQL graphQL(GraphQLSchema schema) {
        return GraphQL.newGraphQL(schema)
                .queryExecutionStrategy(new AsyncExecutionStrategy(new GraphQLExceptionHandler()))
                .mutationExecutionStrategy(new AsyncSerialExecutionStrategy(new GraphQLExceptionHandler()))
                .build();
    }

}
