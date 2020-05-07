package de.hanselmann.shoppinglist.configuration;

import org.springframework.security.access.AccessDeniedException;

import graphql.ExceptionWhileDataFetching;
import graphql.execution.DataFetcherExceptionHandler;
import graphql.execution.DataFetcherExceptionHandlerParameters;
import graphql.execution.ExecutionPath;
import graphql.language.SourceLocation;

public class GraphQLExceptionHandler implements DataFetcherExceptionHandler {

    @Override
    public void accept(DataFetcherExceptionHandlerParameters handlerParameters) {
        Throwable exception = handlerParameters.getException();
        SourceLocation sourceLocation = handlerParameters.getField().getSourceLocation();
        ExecutionPath path = handlerParameters.getPath();

        ShoppingListError shoppingListException = new ShoppingListError(getErrorCode(exception), exception);
        ExceptionWhileDataFetching error = new ExceptionWhileDataFetching(path, shoppingListException, sourceLocation);
        handlerParameters.getExecutionContext().addError(error);

    }

    private int getErrorCode(Throwable exception) {
        if (exception instanceof AccessDeniedException) {
            return 401;
        }

        return 500;
    }

}
