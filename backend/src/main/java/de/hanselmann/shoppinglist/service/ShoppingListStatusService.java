package de.hanselmann.shoppinglist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.repository.ShoppingListItemRepository;

@Service
public class ShoppingListStatusService {

    private ShoppingListItemRepository itemRepository;

    @Autowired
    public ShoppingListStatusService(ShoppingListItemRepository itemRepository) {
        this.itemRepository = itemRepository;
    }

    public int getNumberOfOpenItems() {
        return itemRepository.findByChecked(false).size();
    }

}
