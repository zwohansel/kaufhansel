package de.hanselmann.shoppinglist.service;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.reactivestreams.Publisher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import reactor.core.publisher.Flux;
import reactor.core.publisher.FluxSink;

@Component
public class DefaultShoppingListSubscribers implements ShoppingListSubscribers {

    private final ShoppingListService shoppingListService;
    private final Map<ObjectId, List<FluxSink<List<ShoppingListItemChangedEvent>>>> subscribers = new ConcurrentHashMap<>();

    @Autowired
    public DefaultShoppingListSubscribers(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    @Override
    public Publisher<List<ShoppingListItemChangedEvent>> addSubscriber(String userId) {
        return Flux.create(
                sink -> addNewSubscription(sink, userId),
                FluxSink.OverflowStrategy.BUFFER);
    }

    private void addNewSubscription(FluxSink<List<ShoppingListItemChangedEvent>> subscriber, String userId) {
        ShoppingList shoppingList = shoppingListService.getShoppingListOfUser(userId);
        subscribers
                .computeIfAbsent(shoppingList.getId(), id -> new CopyOnWriteArrayList<>())
                .add(subscriber.onDispose(() -> removeSubscriber(userId, subscriber)));
    }

    private void removeSubscriber(String userId, FluxSink<List<ShoppingListItemChangedEvent>> subscriber) {
        ShoppingList shoppingList = shoppingListService.getShoppingListOfUser(userId);
        var shoppingListSubscribers = subscribers.get(shoppingList.getId());
        if (shoppingListSubscribers != null) {
            shoppingListSubscribers.remove(subscriber);
        }
    }

    @Override
    public void notifyItemsChanged(ShoppingList list, List<ShoppingListItem> items) {
        publishEvent(list, items.stream().map(ShoppingListItemChangedEvent::changedItem).collect(Collectors.toList()));
    }

    @Override
    public void notifyItemsCreated(ShoppingList list, List<ShoppingListItem> items) {
        publishEvent(list, items.stream().map(ShoppingListItemChangedEvent::createdItem).collect(Collectors.toList()));
    }

    @Override
    public void notifyItemsDeleted(ShoppingList list, List<ShoppingListItem> items) {
        publishEvent(list, items.stream().map(ShoppingListItemChangedEvent::deletedItem).collect(Collectors.toList()));
    }

    private void publishEvent(ShoppingList shoppingList, List<ShoppingListItemChangedEvent> events) {
        subscribers.getOrDefault(shoppingList.getId(), Collections.emptyList())
                .forEach(subscriber -> subscriber.next(events));
    }

}
