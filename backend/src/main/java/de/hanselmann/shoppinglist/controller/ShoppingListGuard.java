package de.hanselmann.shoppinglist.controller;

import org.bson.types.ObjectId;
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

    public boolean canAccessShoppingList(String id) {
        return ObjectId.isValid(id) && canAccessShoppingList(new ObjectId(id));
    }

    public boolean canAccessShoppingList(ObjectId id) {
        return userService.findCurrentUser().map(user -> canAccessShoppingList(user, id)).orElse(false);
    }

    private boolean canAccessShoppingList(ShoppingListUser user, ObjectId id) {
        return user.getShoppingLists().stream().anyMatch(ref -> ref.getShoppingListId().equals(id));
    }

    public boolean canEditItemsInShoppingList(String id) {
        return ObjectId.isValid(id) && canEditItemsInShoppingList(new ObjectId(id));
    }

    public boolean canEditItemsInShoppingList(ObjectId id) {
        return userService.findCurrentUser().map(user -> canEditItemsInShoppingList(user, id)).orElse(false);
    }

    private boolean canEditItemsInShoppingList(ShoppingListUser user, ObjectId id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(id))
                .anyMatch(ref -> ref.getRole().canEditItems());
    }

    public boolean canCheckItemsInShoppingList(String id) {
        return ObjectId.isValid(id) && canCheckItemsInShoppingList(new ObjectId(id));
    }

    public boolean canCheckItemsInShoppingList(ObjectId id) {
        return userService.findCurrentUser().map(user -> canCheckItemsInShoppingList(user, id)).orElse(false);
    }

    private boolean canCheckItemsInShoppingList(ShoppingListUser user, ObjectId id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(id))
                .anyMatch(ref -> ref.getRole().canCheckItems());
    }

    public boolean canEditShoppingList(String id) {
        return ObjectId.isValid(id) && canEditShoppingList(new ObjectId(id));
    }

    private boolean canEditShoppingList(ObjectId id) {
        return userService.findCurrentUser().map(user -> canEditShoppingList(user, id)).orElse(false);
    }

    private boolean canEditShoppingList(ShoppingListUser user, ObjectId id) {
        return user.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(id))
                .anyMatch(ref -> ref.getRole().canEditList());
    }

}
