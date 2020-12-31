package de.hanselmann.shoppinglist.controller;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.ShoppingListService;
import de.hanselmann.shoppinglist.service.ShoppingListSubscribers;

@RestController
public class ShoppingListController implements ShoppingListApi {
    private final ShoppingListService shoppingListService;
    private final DtoTransformer dtoTransformer;
    private final ShoppingListSubscribers shoppingListSubscribers;

    @Autowired
    public ShoppingListController(ShoppingListService shoppingListService, DtoTransformer dtoTransformer,
            ShoppingListSubscribers shoppingListSubscribers) {
        this.shoppingListService = shoppingListService;
        this.dtoTransformer = dtoTransformer;
        this.shoppingListSubscribers = shoppingListSubscribers;
    }

    @Override
    public ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(String id) {
        return ResponseEntity
                .of(shoppingListService.getShoppingList(id).map(ShoppingList::getItems).map(dtoTransformer::map));
    }

    @Override
    public ResponseEntity<ShoppingListItemDto> addShoppingListItem(String id, NewShoppingListItemDto item) {
        return ResponseEntity.of(shoppingListService.getShoppingList(id)
                .map(list -> createNewItem(item.getName(), list)).map(dtoTransformer::map));
    }

    private ShoppingListItem createNewItem(String name, ShoppingList list) {
        ShoppingListItem newItem = new ShoppingListItem(name);
        list.addItem(newItem);
        shoppingListService.saveShoppingList(list);
        shoppingListSubscribers.notifyItemsCreated(list, Collections.singletonList(newItem));
        return newItem;
    }

}