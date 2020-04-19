package de.hanselmann.shoppinglist.service;

import java.text.MessageFormat;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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
public class ShoppingListService {
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
    public @GraphQLNonNull ShoppingListItem changeShoppingListItemCheckedState(
            @GraphQLNonNull @GraphQLId @GraphQLArgument(name = "id") String id,
            @GraphQLNonNull @GraphQLArgument(name = "state") boolean state) {

        final ShoppingListItem item = shoppingListRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException(
                        MessageFormat.format("There is no item with ID {0} in the shopping list.", id)));
        item.setChecked(state);
        shoppingListRepository.save(item);
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
