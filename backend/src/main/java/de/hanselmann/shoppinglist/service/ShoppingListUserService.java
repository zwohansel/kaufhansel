package de.hanselmann.shoppinglist.service;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;

@Service
public class ShoppingListUserService {
    private final ShoppingListUserRepository userRepository;

    @Autowired
    public ShoppingListUserService(ShoppingListUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public ShoppingListUser getCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        return getUser(new ObjectId(auth.getName()));
    }

    public ShoppingListUser getUser(ObjectId userId) {
        return userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User does not exist."));
    }

    public void addShoppingListToUser(ShoppingListUser user, ObjectId shoppingListId,
            ShoppingListRole role) {
        ShoppingListReference shoppingListReference = new ShoppingListReference(shoppingListId, role);
        user.addShoppingList(shoppingListReference);
        userRepository.save(user);
    }

    public boolean removeShoppingListFromUser(ShoppingListUser user, ObjectId shoppingListId) {
        user.deleteShoppingList(shoppingListId);
        userRepository.save(user);
        return true;
    }

    public Optional<ShoppingListUser> findByEmailAddress(String emailAddress) {
        if (emailAddress != null) {
            return userRepository.findUserByEmailAddress(emailAddress.toLowerCase());
        } else {
            return Optional.empty();
        }
    }

    public Optional<ShoppingListRole> getRoleForUser(ShoppingListUser user, ObjectId shoppingListId) {
        return user.getShoppingLists().stream()
                .filter(refs -> refs.getShoppingListId().equals(shoppingListId))
                .findAny().map(ShoppingListReference::getRole);
    }

    public void changePermission(ShoppingListUser userToBeChanged, ObjectId shopingListId,
            ShoppingListRole role) {
        ShoppingListReference referenceForUserToBeChanged = userToBeChanged.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(shopingListId))
                .findAny()
                .orElseThrow();
        referenceForUserToBeChanged.setRole(role);
        userRepository.save(userToBeChanged);
    }

}
