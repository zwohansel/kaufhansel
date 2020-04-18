package de.hanselmann.shoppinglist.service;

import static graphql.schema.idl.TypeRuntimeWiring.newTypeWiring;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import graphql.GraphQL;
import graphql.schema.GraphQLSchema;
import graphql.schema.idl.RuntimeWiring;
import graphql.schema.idl.SchemaGenerator;
import graphql.schema.idl.SchemaParser;
import graphql.schema.idl.TypeDefinitionRegistry;

@Component
public class GraphQLProvider {

	private GraphQL graphQL;

	@Autowired
	public GraphQLProvider(ShoppingListDataFetchers dataFetchers) throws IOException, URISyntaxException {
		Resource schemaResource = new ClassPathResource("schema.graphqls");
		this.graphQL = GraphQL.newGraphQL(buildSchema(schemaResource.getFile(), dataFetchers)).build();
	}

	private GraphQLSchema buildSchema(File schemaFile, ShoppingListDataFetchers dataFetchers) {
		TypeDefinitionRegistry registry = new SchemaParser().parse(schemaFile);

		RuntimeWiring wiring = RuntimeWiring.newRuntimeWiring() //
				.type(newTypeWiring("Query") //
						.dataFetcher("shoppingListItems", dataFetchers.getItems()))
				.type(newTypeWiring("ShoppingListItem") //
						.dataFetcher("_id", dataFetchers.getItemId()))
				.type(newTypeWiring("Mutation") //
						.dataFetcher("createShoppingListItem", dataFetchers.createItem())
						.dataFetcher("changeShoppingListItemCheckedState", dataFetchers.changeItemCheckedState())
						.dataFetcher("deleteShoppingListItem", dataFetchers.deleteItem())
						.dataFetcher("clearShoppingList", dataFetchers.clearItems()))
				.build();

		SchemaGenerator schemaGenerator = new SchemaGenerator();
		return schemaGenerator.makeExecutableSchema(registry, wiring);
	}

	@Bean
	public GraphQL graphQL() {
		return graphQL;
	}

}
