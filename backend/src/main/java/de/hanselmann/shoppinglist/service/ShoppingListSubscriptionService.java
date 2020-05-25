package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import org.reactivestreams.Publisher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import io.leangen.graphql.annotations.GraphQLSubscription;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

@Service
@GraphQLApi
public class ShoppingListSubscriptionService {
    private final static Logger LOGGER = LoggerFactory.getLogger(ShoppingListService.class);

    public static List<FluxSink<ShoppingListItem>> subscribers = new CopyOnWriteArrayList<>();

    @GraphQLSubscription
    public Publisher<ShoppingListItem> shoppingListChanged() {
        LOGGER.info("Added subscription");
        return Flux.<ShoppingListItem>create(
                subscriber -> subscribers.add(subscriber.onDispose(() -> subscribers.remove(subscriber))),
                FluxSink.OverflowStrategy.BUFFER);
    }

}
