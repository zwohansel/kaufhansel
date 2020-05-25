package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.repository.ShopppingListItemRepository;
import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLId;
import io.leangen.graphql.annotations.GraphQLMutation;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLQuery;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
@PreAuthorize("hasRole('SHOPPER')")
public class ShoppingListService {
    private final static Logger LOGGER = LoggerFactory.getLogger(ShoppingListService.class);

    private ShopppingListItemRepository shoppingListRepository;

    @Autowired
    public ShoppingListService(ShopppingListItemRepository shoppingListRepository) {
        this.shoppingListRepository = shoppingListRepository;
    }

    @GraphQLQuery
    public @GraphQLNonNull List<@GraphQLNonNull ShoppingListItem> getShoppingListItems() {
        return shoppingListRepository.findAll();
    }

    @GraphQLMutation
    public @GraphQLNonNull ShoppingListItem createShoppingListItem(
            @GraphQLNonNull @GraphQLArgument(name = "name") String name) {
        final ShoppingListItem item = new ShoppingListItem(name);
        return shoppingListRepository.save(item);
    }

    @GraphQLMutation
    public @GraphQLNonNull ShoppingListItem updateShoppingListItem(
            @GraphQLNonNull @GraphQLId @GraphQLArgument(name = "id") String id,
            @GraphQLArgument(name = "state") Boolean state, @GraphQLArgument(name = "assignee") String assignee) {

        final ShoppingListItem item = shoppingListRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(
                        MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));

        if (state != null) {
            item.setChecked(state);
        }

        if (assignee != null) {
            item.setAssignee(assignee);
        }

        shoppingListRepository.save(item);
        LOGGER.info("Notify subscribers");
        ShoppingListSubscriptionService.subscribers.forEach(subscriber -> {
            LOGGER.info("NEXT: ", subscriber);
            subscriber.next(item);
        });

        return item;
    }

    @GraphQLMutation
    public @GraphQLNonNull @GraphQLId String deleteShoppingListItem(
            @GraphQLNonNull @GraphQLId @GraphQLArgument(name = "id") String id) {
        shoppingListRepository.deleteById(id);
        return id;
    }

    @GraphQLMutation
    public @GraphQLNonNull boolean clearShoppingList() {
        shoppingListRepository.deleteAll();
        return true;
    }

}
