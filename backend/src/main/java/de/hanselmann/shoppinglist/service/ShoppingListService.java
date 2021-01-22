package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.MongoTransactionException;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.ShoppingListUserReference;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;

@Service
public class ShoppingListService {
    private final ShoppingListRepository shoppingListRepository;
    private final ShoppingListUserService userService;

    @Autowired
    public ShoppingListService(ShoppingListRepository shoppingListRepository,
            ShoppingListUserService userService) {
        this.shoppingListRepository = shoppingListRepository;
        this.userService = userService;
    }

    @Transactional
    public ShoppingList createShoppingListForCurrentUser(String name) {
        ShoppingListUser user = userService.getCurrentUser();
        ShoppingList shoppingList = new ShoppingList();
        shoppingList.setName(name);
        shoppingList.addUser(new ShoppingListUserReference(user.getId()));
        shoppingListRepository.save(shoppingList);
        userService.addShoppingListToUser(user, shoppingList.getId());
        return shoppingList;
    }

    public Stream<ShoppingList> getShoppingListsOfCurrentUser() {
        return getShoppingListsOfUser(userService.getCurrentUser());
    }

    private Stream<ShoppingList> getShoppingListsOfUser(ShoppingListUser user) {
        return getShoppingLists(user.getShoppingLists());
    }

    private Stream<ShoppingList> getShoppingLists(List<ShoppingListReference> references) {
        return references.stream().map(ref -> shoppingListRepository.findById(ref.getShoppingListId()))
                .filter(Optional::isPresent)
                .map(Optional::get);
    }

    public ShoppingList getFirstShoppingListOfCurrentUser() {
        return getFirstShoppingListOfUser(userService.getCurrentUser().getId());
    }

    public ShoppingList getFirstShoppingListOfUser(ObjectId userId) {
        return getShoppingListsOfUser(userService.getUser(userId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("User has no shopping list."));
    }

    public ShoppingListItem createNewItem(String name, @Nullable String category, ShoppingList list) {
        ShoppingListItem newItem = new ShoppingListItem(name);
        newItem.setAssignee(category);
        list.addItem(newItem);
        saveShoppingList(list);
        return newItem;
    }

    public void saveShoppingList(ShoppingList list) {
        shoppingListRepository.save(list);
    }

    public Optional<ShoppingList> getShoppingList(ObjectId id) {
        return shoppingListRepository.findById(id);
    }

    public boolean deleteShoppingList(ObjectId id) {
        try {
            return tryDeleteShoppingList(id);
        } catch (MongoTransactionException e) {
            return false;
        }
    }

    @Transactional
    private boolean tryDeleteShoppingList(ObjectId shoppingListId) {
        ShoppingList list = getShoppingList(shoppingListId).orElse(null);

        if (list == null) {
            return false;
        }

        ShoppingListUser user = userService.getCurrentUser();
        if (!userService.removeShoppingListFromUser(user, shoppingListId)) {
            return false;
        }

        if (!list.deleteUser(user.getId())) {
            return false;
        }

        if (list.getUsers().isEmpty()) {
            shoppingListRepository.deleteById(shoppingListId);
        } else {
            shoppingListRepository.save(list);
        }

        return true;
    }
}
