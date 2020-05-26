package de.hanselmann.shoppinglist.service;

import org.reactivestreams.Publisher;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
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
    public Publisher<ShoppingListItem> shoppingListChanged() {
        return shoppingListSubscribers.addSubscriber();
    }

}
