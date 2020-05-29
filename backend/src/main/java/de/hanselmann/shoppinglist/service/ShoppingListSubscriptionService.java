package de.hanselmann.shoppinglist.service;

import org.reactivestreams.Publisher;
import org.springframework.stereotype.Service;

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
    public Publisher<ShoppingListItemChangedEvent> shoppingListChanged() {
        return shoppingListSubscribers.addSubscriber();
    }

}
