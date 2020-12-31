package de.hanselmann.shoppinglist.service;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ShoppingList;
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

    public ShoppingList getShoppingListOfCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        return getShoppingListOfUser(auth.getName());
    }

    public ShoppingList getShoppingListOfUser(String userId) {
        return userRepository.findById(userId)
                .flatMap(user -> shoppingListRepository.findById(user.getShoppingListId()))
                .orElseThrow(() -> new IllegalArgumentException("User does not exist or has no shopping list."));
    }

    public void saveShoppingList(ShoppingList list) {
        shoppingListRepository.save(list);
    }
    
    public Optional<ShoppingList> getShoppingList(String id) {
    	return shoppingListRepository.findById(id);
    }
}
