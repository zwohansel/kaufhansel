package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

import org.reactivestreams.Publisher;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

@Component
public class DefaultShoppingListSubscribers implements ShoppingListSubscribers {

    private final List<FluxSink<List<ShoppingListItemChangedEvent>>> subscribers = new CopyOnWriteArrayList<>();

    @Override
    public Publisher<List<ShoppingListItemChangedEvent>> addSubscriber() {
        return Flux.create(
                this::addNewSubscription,
                FluxSink.OverflowStrategy.BUFFER);
    }

    private void addNewSubscription(FluxSink<List<ShoppingListItemChangedEvent>> subscriber) {
        subscribers.add(subscriber.onDispose(() -> removeSubscriber(subscriber)));
    }

    private void removeSubscriber(FluxSink<List<ShoppingListItemChangedEvent>> subscriber) {
        subscribers.remove(subscriber);
    }

    @Override
    public void notifyItemsChanged(List<ShoppingListItem> items) {
        publishEvent(items.stream().map(ShoppingListItemChangedEvent::changedItem).collect(Collectors.toList()));
    }

    @Override
    public void notifyItemsCreated(List<ShoppingListItem> items) {
        publishEvent(items.stream().map(ShoppingListItemChangedEvent::createdItem).collect(Collectors.toList()));
    }

    @Override
    public void notifyItemsDeleted(List<ShoppingListItem> items) {
        publishEvent(items.stream().map(ShoppingListItemChangedEvent::deletedItem).collect(Collectors.toList()));
    }

    private void publishEvent(List<ShoppingListItemChangedEvent> events) {
        subscribers.forEach(subscriber -> subscriber.next(events));
    }

}
