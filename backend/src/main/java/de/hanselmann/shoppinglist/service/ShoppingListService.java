package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.TransactionException;
import org.springframework.transaction.support.TransactionTemplate;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.ShoppingListUserReference;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;

@Service
public class ShoppingListService {
    private final ShoppingListRepository shoppingListRepository;
    private final ShoppingListUserService userService;
    private TransactionTemplate transactionTemplate;

    @Autowired
    public ShoppingListService(ShoppingListRepository shoppingListRepository,
            ShoppingListUserService userService,
            MongoTransactionManager transactionManager) {
        this.shoppingListRepository = shoppingListRepository;
        this.userService = userService;
        transactionTemplate = new TransactionTemplate(transactionManager);
    }

    public @Nullable ShoppingList createShoppingListForCurrentUser(String name) {
        try {
            return transactionTemplate.execute(status -> {
                ShoppingListUser user = userService.getCurrentUser();
                ShoppingList shoppingList = new ShoppingList();
                shoppingList.setName(name);
                shoppingList.addUser(new ShoppingListUserReference(user.getId()));
                shoppingListRepository.save(shoppingList);
                userService.addShoppingListToUser(user, shoppingList.getId(), ShoppingListRole.ADMIN);
                return shoppingList;
            });
        } catch (TransactionException e) {
            return null;
        }
    }

    public @Nullable ShoppingListReference addUserToShoppingList(ObjectId shoppingListId, ShoppingListUser user) {
        try {
            return transactionTemplate.execute(status -> {
                ShoppingList shoppingList = shoppingListRepository.findById(shoppingListId)
                        .orElseThrow(() -> new IllegalArgumentException("User does not exist."));

                if (shoppingList.getUsers().stream().anyMatch(listUser -> listUser.getUserId().equals(user.getId()))) {
                    throw new IllegalArgumentException("Shopping list is alread shared with user.");
                }

                shoppingList.addUser(new ShoppingListUserReference(user.getId()));
                shoppingListRepository.save(shoppingList);
                return userService.addShoppingListToUser(user, shoppingListId, ShoppingListRole.READ_WRITE);
            });

        } catch (TransactionException e) {
            return null;
        }
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

    public Optional<ShoppingList> findShoppingList(ObjectId id) {
        return shoppingListRepository.findById(id);
    }

    public boolean deleteShoppingList(ObjectId id) {
        try {
            transactionTemplate.executeWithoutResult(status -> tryDeleteShoppingList(id));
            return true;
        } catch (TransactionException e) {
            return false;
        }
    }

    private void tryDeleteShoppingList(ObjectId shoppingListId) {
        ShoppingList list = findShoppingList(shoppingListId).orElseThrow();

        ShoppingListUser user = userService.getCurrentUser();
        userService.removeShoppingListFromUser(user, shoppingListId);

        list.removeUserFromShoppingList(user.getId());

        if (list.getUsers().isEmpty()) {
            shoppingListRepository.deleteById(shoppingListId);
        } else {
            shoppingListRepository.save(list);
        }
    }

    public void removeUserFromShoppingList(ObjectId shoppingListId, ObjectId userId) {
        shoppingListRepository.findById(shoppingListId).ifPresentOrElse(
                shoppingList -> {
                    shoppingList.removeUserFromShoppingList(userId);
                    shoppingListRepository.save(shoppingList);
                },
                () -> {
                    throw new IllegalArgumentException("");
                });
    }

    public @Nullable List<ShoppingListItem> uncheckAllItems(ShoppingList list) {
        try {
            return transactionTemplate.execute(status -> {
                List<ShoppingListItem> itemsToUncheck = list.getItems().stream()
                        .filter(ShoppingListItem::isChecked)
                        .collect(Collectors.toList());
                itemsToUncheck.forEach(item -> item.setChecked(false));
                shoppingListRepository.save(list);
                return itemsToUncheck;
            });
        } catch (TransactionException e) {
            return null;
        }
    }

    public @Nullable List<ShoppingListItem> removeAllCategories(ShoppingList list) {
        try {
            return transactionTemplate.execute(status -> {
                List<ShoppingListItem> itemsToChange = list.getItems().stream()
                        .filter(item -> item.getAssignee() != null && !item.getAssignee().isBlank())
                        .collect(Collectors.toList());
                itemsToChange.forEach(item -> item.setAssignee(""));
                shoppingListRepository.save(list);
                return itemsToChange;
            });
        } catch (TransactionException e) {
            return null;
        }
    }

    public @Nullable List<ShoppingListItem> removeAllItems(ShoppingList list) {
        try {
            return transactionTemplate.execute(status -> {
                List<ShoppingListItem> deletedItems = list.clearItems();
                shoppingListRepository.save(list);
                return deletedItems;
            });
        } catch (TransactionException e) {
            return null;
        }
    }

    public boolean moveShoppingListItem(ShoppingList list, ShoppingListItem item, int targetIndex) {
        if (list.moveItem(item, targetIndex)) {
            shoppingListRepository.save(list);
            return true;
        }
        return false;
    }

    public void renameList(ObjectId shoppingListId, String name) {
        ShoppingList list = findShoppingList(shoppingListId).orElseThrow();
        list.setName(name);
        shoppingListRepository.save(list);
    }
}
