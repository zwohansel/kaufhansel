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

    private final List<FluxSink<ShoppingListItemChangedEvent>> subscribers = new CopyOnWriteArrayList<>();

    @Override
    public Publisher<ShoppingListItemChangedEvent> addSubscriber() {
        return Flux.create(
                this::addNewSubscription,
                FluxSink.OverflowStrategy.BUFFER);
    }

    private void addNewSubscription(FluxSink<ShoppingListItemChangedEvent> subscriber) {
        subscribers.add(subscriber.onDispose(() -> removeSubscriber(subscriber)));
    }

    private void removeSubscriber(FluxSink<ShoppingListItemChangedEvent> subscriber) {
        subscribers.remove(subscriber);
    }

    @Override
    public void notifyItemChanged(ShoppingListItem item) {
        publishEvent(ShoppingListItemChangedEvent.changedItem(item));
    }

    @Override
    public void notifyItemCreated(ShoppingListItem item) {
        publishEvent(ShoppingListItemChangedEvent.createdItem(item));
    }

    @Override
    public void notifyItemDeleted(ShoppingListItem item) {
        publishEvent(ShoppingListItemChangedEvent.deletedItem(item));
    }

    private void publishEvent(ShoppingListItemChangedEvent event) {
        subscribers.forEach(subscriber -> subscriber.next(event));
    }

}
