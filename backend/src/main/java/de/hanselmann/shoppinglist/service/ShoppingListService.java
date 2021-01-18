package de.hanselmann.shoppinglist.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.model.ShoppingListUserReference;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;

@Service
public class ShoppingListService {
    private ShoppingListUserRepository userRepository;
    private ShoppingListRepository shoppingListRepository;

    @Autowired
    public ShoppingListService(ShoppingListUserRepository userRepository,
            ShoppingListRepository shoppingListRepository) {
        this.userRepository = userRepository;
        this.shoppingListRepository = shoppingListRepository;
    }

    public ShoppingList createShoppingListForCurrentUser(String name) {
        ShoppingListUser user = getCurrentUser();
        ShoppingList shoppingList = new ShoppingList();
        shoppingList.setName(name);
        shoppingList.addUser(new ShoppingListUserReference(user.getId()));
        shoppingListRepository.save(shoppingList);
        user.addShoppingList(new ShoppingListReference(shoppingList.getId()));
        userRepository.save(user);
        return shoppingList;
    }

    private ShoppingListUser getCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        return getUser(auth.getName());
    }

    private ShoppingListUser getUser(String userId) {
        return userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User does not exist."));
    }

    public Stream<ShoppingList> getShoppingListsOfCurrentUser() {
        return getShoppingListsOfUser(getCurrentUser());
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
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        return getShoppingListOfUser(auth.getName());
    }

    public ShoppingList getShoppingListOfUser(String userId) {
        return getShoppingListsOfUser(getUser(userId))
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
}
