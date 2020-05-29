package de.hanselmann.shoppinglist.model;

import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLQuery;

public class GraphQlResponse<T> {
    private final boolean success;
    private final String message;
    private final T data;

    private GraphQlResponse(boolean success, String message, T data) {
        this.success = success;
        this.message = message;
        this.data = data;
    }

    public static <T> GraphQlResponse<T> success(T data) {
        return new GraphQlResponse<>(true, "", data);
    }

    public static GraphQlResponse<Void> fail(String message) {
        return new GraphQlResponse<>(false, message, null);
    }

    @GraphQLQuery(name = "success")
    public boolean isSuccess() {
        return success;
    }

    @GraphQLQuery(name = "message")
    public @GraphQLNonNull String getMessage() {
        return message;
    }

    @GraphQLQuery(name = "data")
    public T getData() {
        return data;
    }

}
