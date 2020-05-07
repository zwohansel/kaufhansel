package de.hanselmann.shoppinglist.configuration;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import graphql.ErrorType;
import graphql.GraphQLError;
import graphql.language.SourceLocation;

public class ShoppingListError extends RuntimeException implements GraphQLError {

    private static final long serialVersionUID = -551895862657852319L;

    private final int errorCode;
    private final Throwable exception;

    public ShoppingListError(int errorCode, Throwable exception) {
        this.errorCode = errorCode;
        this.exception = exception;
    }

    @Override
    public Map<String, Object> getExtensions() {
        Map<String, Object> customErrorAttributes = new LinkedHashMap<>();
        customErrorAttributes.put("code", errorCode);
        return customErrorAttributes;
    }

    @Override
    public String getMessage() {
        return exception.getMessage();
    }

    @Override
    public List<SourceLocation> getLocations() {
        return null;
    }

    @Override
    public ErrorType getErrorType() {
        return null;
    }
}
