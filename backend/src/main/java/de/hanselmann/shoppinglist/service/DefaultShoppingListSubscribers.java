package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import org.reactivestreams.Publisher;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

@Component
public class DefaultShoppingListSubscribers implements ShoppingListSubscribers {

    private final List<FluxSink<ShoppingListItem>> subscribers = new CopyOnWriteArrayList<>();

    @Override
    public Publisher<ShoppingListItem> addSubscriber() {
        return Flux.<ShoppingListItem>create(
                subscriber -> subscribers.add(subscriber.onDispose(() -> subscribers.remove(subscriber))),
                FluxSink.OverflowStrategy.BUFFER);
    }

    @Override
    public void notifyItemChanged(ShoppingListItem changedShoppingListItem) {
        subscribers.forEach(subscriber -> {
            subscriber.next(changedShoppingListItem);
        });
    }

}
