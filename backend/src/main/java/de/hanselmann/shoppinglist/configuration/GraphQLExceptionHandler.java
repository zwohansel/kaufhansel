package de.hanselmann.shoppinglist.configuration;

import org.springframework.security.access.AccessDeniedException;

import graphql.ExceptionWhileDataFetching;
import graphql.GraphQLError;
import graphql.execution.DataFetcherExceptionHandler;
import graphql.execution.DataFetcherExceptionHandlerParameters;
import graphql.execution.DataFetcherExceptionHandlerResult;
import graphql.execution.ExecutionPath;
import graphql.language.SourceLocation;

/**
 * GraphQl HTTP status code is always 200. To differentiate between an
 * authentication error and other errors we put the status code into the
 * extensions map of the {@linkplain GraphQLError} response. This allows us to
 * redirect to the login page in case the user is not logged in.
 */
public class GraphQLExceptionHandler implements DataFetcherExceptionHandler {

    @Override
    public DataFetcherExceptionHandlerResult onException(DataFetcherExceptionHandlerParameters handlerParameters) {
        Throwable exception = handlerParameters.getException();
        SourceLocation sourceLocation = handlerParameters.getSourceLocation();
        ExecutionPath path = handlerParameters.getPath();

        ShoppingListError shoppingListException = new ShoppingListError(getErrorCode(exception), exception);
        ExceptionWhileDataFetching error = new ExceptionWhileDataFetching(path, shoppingListException, sourceLocation);

        return DataFetcherExceptionHandlerResult.newResult(error).build();
    }

    private int getErrorCode(Throwable exception) {
        if (exception instanceof AccessDeniedException) {
            return 401;
        }

        return 500;
    }

}
