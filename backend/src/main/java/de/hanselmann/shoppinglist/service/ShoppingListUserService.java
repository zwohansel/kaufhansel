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

    public ShoppingListReference addShoppingListToUser(ShoppingListUser user, ObjectId shoppingListId,
            ShoppingListRole role) {
        ShoppingListReference shoppingListReference = new ShoppingListReference(shoppingListId, role);
        user.addShoppingList(shoppingListReference);
        userRepository.save(user);
        return shoppingListReference;
    }

    public void removeShoppingListFromUser(ShoppingListUser user, ObjectId shoppingListId) {
        user.deleteShoppingList(shoppingListId);
        userRepository.save(user);
    }

    public Optional<ShoppingListUser> findByEmailAddress(String emailAddress) {
        if (emailAddress != null) {
            return userRepository.findUserByEmailAddress(emailAddress.toLowerCase());
        } else {
            return Optional.empty();
        }
    }

}
