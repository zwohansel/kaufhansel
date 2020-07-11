package de.hanselmann.shoppinglist.service;

import java.util.List;

import org.reactivestreams.Publisher;
import org.springframework.stereotype.Service;

import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLSubscription;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
public class ShoppingListSubscriptionService {
    private final ShoppingListSubscribers shoppingListSubscribers;

    public ShoppingListSubscriptionService(ShoppingListSubscribers shoppingListSubscribers) {
        this.shoppingListSubscribers = shoppingListSubscribers;
    }

    @GraphQLSubscription
    public Publisher<List<ShoppingListItemChangedEvent>> shoppingListChanged(
            @GraphQLNonNull @GraphQLArgument(name = "userId") String userId) {
        return shoppingListSubscribers.addSubscriber(userId);
    }

}
