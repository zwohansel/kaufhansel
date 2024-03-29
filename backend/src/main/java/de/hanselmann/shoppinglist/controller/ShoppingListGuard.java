package de.hanselmann.shoppinglist.controller;

import java.util.function.Predicate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListItemsRepository;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@Component("shoppingListGuard")
public class ShoppingListGuard {
    private final ShoppingListUserService userService;
    private final ShoppingListItemsRepository itemsRepository;

    @Autowired
    public ShoppingListGuard(ShoppingListUserService userService, ShoppingListItemsRepository itemsRepository) {
        this.userService = userService;
        this.itemsRepository = itemsRepository;
    }

    private boolean checkAccessForCurrentUser(Predicate<ShoppingListUser> predicate) {
        return userService.findCurrentUser().map(predicate::test).orElse(false);
    }

    public boolean canAccessShoppingList(long listId) {
        return checkAccessForCurrentUser(user -> canAccessShoppingList(user, listId));
    }

    public boolean canAccessShoppingListItem(long itemId) {
        return checkAccessForCurrentUser(user -> canUserAccessShoppingListItem(user, itemId));
    }

    private boolean canUserAccessShoppingListItem(ShoppingListUser currentUser, long itemId) {
        return itemsRepository.findById(itemId)
                .map(item -> item.getList().getPermissionOfUser(currentUser).isPresent())
                .orElse(false);
    }

    private boolean canAccessShoppingList(ShoppingListUser user, long listId) {
        return user.getShoppingListPermissions().stream()
                .anyMatch(permission -> permission.getList().getId() == listId);
    }

    public boolean canEditItemsInShoppingList(long id) {
        return checkAccessForCurrentUser(user -> canEditItemsInShoppingList(user, id));
    }

    private boolean canEditItemsInShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == id)
                .anyMatch(permission -> permission.getRole().canEditItems());
    }

    public boolean canCheckItemsInShoppingList(long id) {
        return checkAccessForCurrentUser(user -> canCheckItemsInShoppingList(user, id));
    }

    private boolean canCheckItemsInShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == id)
                .anyMatch(permission -> permission.getRole().canCheckItems());
    }

    public boolean canEditShoppingList(long id) {
        return checkAccessForCurrentUser(user -> canEditShoppingList(user, id));
    }

    private boolean canEditShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == id)
                .anyMatch(permission -> permission.getRole().canEditList());
    }

    public boolean canDeleteUser(long id) {
        return checkAccessForCurrentUser(user -> user.getId() == id);
    }

}
