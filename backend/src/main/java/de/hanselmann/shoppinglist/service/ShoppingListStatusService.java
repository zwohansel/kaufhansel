package de.hanselmann.shoppinglist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ShoppingListStatusService {

    private ShoppingListService shoppingListService;

    @Autowired
    public ShoppingListStatusService(ShoppingListService shoppingListService) {
        this.shoppingListService = shoppingListService;
    }

    public int getNumberOfOpenItems() {
        return shoppingListService.getFirstShoppingListOfCurrentUser().getByChecked(false).size();
    }

}
