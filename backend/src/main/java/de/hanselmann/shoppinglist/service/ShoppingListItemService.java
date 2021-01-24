package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import io.leangen.graphql.annotations.GraphQLArgument;
import io.leangen.graphql.annotations.GraphQLId;
import io.leangen.graphql.annotations.GraphQLMutation;
import io.leangen.graphql.annotations.GraphQLNonNull;
import io.leangen.graphql.annotations.GraphQLQuery;
import io.leangen.graphql.spqr.spring.annotations.GraphQLApi;

@Service
@GraphQLApi
@PreAuthorize("hasRole('SHOPPER')")
public class ShoppingListItemService {
    private ShoppingListService shoppingListService;
    private ShoppingListSubscribers shoppingListSubscribers;

    @Autowired
    public ShoppingListItemService(
            ShoppingListService shoppingListUserService,
            ShoppingListSubscribers shoppingListSubscribers) {
        this.shoppingListService = shoppingListUserService;
        this.shoppingListSubscribers = shoppingListSubscribers;
    }

    @GraphQLQuery
    public @GraphQLNonNull List<@GraphQLNonNull ShoppingListItem> getShoppingListItems() {
        return shoppingListService.getFirstShoppingListOfCurrentUser().getItems();
    }

    @GraphQLMutation
    public @GraphQLNonNull ShoppingListItem createShoppingListItem(
            @GraphQLNonNull @GraphQLArgument(name = "name") String name) {
        ShoppingList shoppingList = shoppingListService.getFirstShoppingListOfCurrentUser();
        ShoppingListItem item = new ShoppingListItem(name);
        shoppingList.addItem(item);
        shoppingListService.saveShoppingList(shoppingList);
        shoppingListSubscribers.notifyItemsCreated(shoppingList, Arrays.asList(item));

        return item;
    }

    @GraphQLMutation
    public @GraphQLNonNull List<ShoppingListItem> updateShoppingListItems(
            @GraphQLNonNull @GraphQLArgument(name = "items") List<@GraphQLNonNull ShoppingListItem> items) {
        ShoppingList shoppingList = shoppingListService.getFirstShoppingListOfCurrentUser();

        List<ShoppingListItem> changedItems = new ArrayList<>();
        for (ShoppingListItem requestItem : items) {

            final String id = requestItem.getId();

            final ShoppingListItem item = shoppingList.findItemById(id)
                    .orElseThrow(() -> new IllegalArgumentException(
                            MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));

            if (requestItem.isChecked() != null) {
                item.setChecked(requestItem.isChecked());
            }

            if (requestItem.getAssignee() != null) {
                item.setAssignee(requestItem.getAssignee());
            }

            changedItems.add(item);

        }

        shoppingListService.saveShoppingList(shoppingList);
        shoppingListSubscribers.notifyItemsChanged(shoppingList, changedItems);

        return changedItems;
    }

    @GraphQLMutation
    public @GraphQLNonNull @GraphQLId String deleteShoppingListItem(
            @GraphQLNonNull @GraphQLId @GraphQLArgument(name = "id") String id) {
        ShoppingList shoppingList = shoppingListService.getFirstShoppingListOfCurrentUser();
        Optional<ShoppingListItem> deltedItem = shoppingList.deleteItemById(id);
        if (deltedItem.isPresent()) {
            shoppingListService.saveShoppingList(shoppingList);
            shoppingListSubscribers.notifyItemsDeleted(shoppingList, Arrays.asList(deltedItem.get()));
        }

        return id;
    }

    @GraphQLMutation
    public @GraphQLNonNull boolean clearShoppingList() {
        ShoppingList shoppingList = shoppingListService.getFirstShoppingListOfCurrentUser();
        List<ShoppingListItem> items = shoppingList.clearItems();
        shoppingListService.saveShoppingList(shoppingList);
        shoppingListSubscribers.notifyItemsDeleted(shoppingList, items);
        return true;
    }

}
