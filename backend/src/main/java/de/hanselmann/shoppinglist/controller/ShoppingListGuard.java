package de.hanselmann.shoppinglist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@Component("shoppingListGuard")
public class ShoppingListGuard {
    private final ShoppingListUserService userService;

    @Autowired
    public ShoppingListGuard(ShoppingListUserService userService) {
        this.userService = userService;
    }

    public boolean canAccessShoppingList(long id) {
        return userService.findCurrentUser().map(user -> canAccessShoppingList(user, id)).orElse(false);
    }

    private boolean canAccessShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingLists().stream().anyMatch(ref -> ref.getShoppingListId() == id);
    }

    public boolean canEditItemsInShoppingList(long id) {
        return userService.findCurrentUser().map(user -> canEditItemsInShoppingList(user, id)).orElse(false);
    }

    private boolean canEditItemsInShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId() == id)
                .anyMatch(ref -> ref.getRole().canEditItems());
    }

    public boolean canCheckItemsInShoppingList(long id) {
        return userService.findCurrentUser().map(user -> canCheckItemsInShoppingList(user, id)).orElse(false);
    }

    private boolean canCheckItemsInShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId() == id)
                .anyMatch(ref -> ref.getRole().canCheckItems());
    }

    public boolean canEditShoppingList(long id) {
        return userService.findCurrentUser().map(user -> canEditShoppingList(user, id)).orElse(false);
    }

    private boolean canEditShoppingList(ShoppingListUser user, long id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId() == id)
                .anyMatch(ref -> ref.getRole().canEditList());
    }

    public boolean canDeleteUser(long userToBeDeletedId) {
        boolean userCanBeDeleted = userService.findUser(userToBeDeletedId)
                .map(user -> !user.isSuperUser()).orElse(false);
        boolean currentUserCanDeleteUser = userService.getCurrentUser().getId() == userToBeDeletedId
                || userService.getCurrentUser().isSuperUser();
        return userCanBeDeleted && currentUserCanDeleteUser;
    }

}
