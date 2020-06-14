package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.repository.ShoppingListItemRepository;
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
    private ShoppingListItemRepository shoppingListRepository;
    private ShoppingListSubscribers shoppingListSubscribers;

    @Autowired
    public ShoppingListService(ShoppingListItemRepository shoppingListRepository,
            ShoppingListSubscribers shoppingListSubscribers) {
        this.shoppingListRepository = shoppingListRepository;
        this.shoppingListSubscribers = shoppingListSubscribers;
    }

    @GraphQLQuery
    public @GraphQLNonNull List<@GraphQLNonNull ShoppingListItem> getShoppingListItems() {
        return shoppingListRepository.findAll();
    }

    @GraphQLMutation
    public @GraphQLNonNull ShoppingListItem createShoppingListItem(
            @GraphQLNonNull @GraphQLArgument(name = "name") String name) {
        final ShoppingListItem item = new ShoppingListItem(name);
        ShoppingListItem createdItem = shoppingListRepository.save(item);

        shoppingListSubscribers.notifyItemCreated(createdItem);

        return createdItem;
    }

    @GraphQLMutation
    public @GraphQLNonNull List<ShoppingListItem> updateShoppingListItems(
            @GraphQLNonNull @GraphQLArgument(name = "items") List<@GraphQLNonNull ShoppingListItem> items) {

        List<ShoppingListItem> response = new ArrayList<>();

        for (ShoppingListItem requestItem : items) {

            final String id = requestItem.getId();

            final ShoppingListItem item = shoppingListRepository.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException(
                            MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));

            if (requestItem.isChecked() != null) {
                item.setChecked(requestItem.isChecked());
            }

            if (requestItem.getAssignee() != null) {
                item.setAssignee(requestItem.getAssignee());
            }

            shoppingListRepository.save(item);

            shoppingListSubscribers.notifyItemChanged(item);

            response.add(item);

        }

        return response;
    }

    @GraphQLMutation
    public @GraphQLNonNull @GraphQLId String deleteShoppingListItem(
            @GraphQLNonNull @GraphQLId @GraphQLArgument(name = "id") String id) {

        Optional<ShoppingListItem> item = shoppingListRepository.findById(id);

        if (item.isPresent()) {
            shoppingListRepository.deleteById(id);
            shoppingListSubscribers.notifyItemDeleted(item.get());
        }

        return id;
    }

    @GraphQLMutation
    public @GraphQLNonNull boolean clearShoppingList() {

        List<ShoppingListItem> items = shoppingListRepository.findAll();
        shoppingListRepository.deleteAll();

        items.forEach(shoppingListSubscribers::notifyItemDeleted);

        return true;
    }

}
