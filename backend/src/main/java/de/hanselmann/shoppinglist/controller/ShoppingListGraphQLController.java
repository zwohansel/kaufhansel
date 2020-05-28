package de.hanselmann.shoppinglist.controller;

import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.NativeWebRequest;

import graphql.GraphQL;
import io.leangen.graphql.spqr.spring.web.GraphQLController;
import io.leangen.graphql.spqr.spring.web.GraphQLExecutor;
import io.leangen.graphql.spqr.spring.web.dto.GraphQLRequest;
import io.leangen.graphql.spqr.spring.web.servlet.DefaultGraphQLController;

/**
 * Custom implementation of the {@linkplain DefaultGraphQLController} that fixes
 * websocket problem with Firefox: <a href=
 * "https://github.com/leangen/graphql-spqr-spring-boot-starter/pull/53">See
 * issue</a>
 * <p>
 * This is a temporary fix until a new version of spqr-spring-boot-starter
 * (>0.0.4) is available.
 */
@RestController
@CrossOrigin
public class ShoppingListGraphQLController extends GraphQLController<NativeWebRequest> {

    @Autowired
    public ShoppingListGraphQLController(GraphQL graphQL, GraphQLExecutor<NativeWebRequest> executor) {
        super(graphQL, executor);
        LoggerFactory.getLogger(getClass()).info("Using ShoppingListGraphQLController");
    }

    @Override
    @GetMapping(value = "${graphql.spqr.http.endpoint:/graphql}", produces = MediaType.APPLICATION_JSON_VALUE, headers = {
            "Connection!=Upgrade", "Connection!=keep-alive, Upgrade" })
    @ResponseBody
    public Object executeGet(GraphQLRequest graphQLRequest, NativeWebRequest request) {
        return executor.execute(graphQL, graphQLRequest, request);
    }

}
