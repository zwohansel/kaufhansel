package de.hanselmann.shoppinglist.controller;

import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.ShoppingListService;
import de.hanselmann.shoppinglist.service.ShoppingListSubscribers;

@RestController
public class ShoppingListController implements ShoppingListApi {
    private final ShoppingListService shoppingListService;
    private final DtoTransformer dtoTransformer;
    private final ShoppingListSubscribers shoppingListSubscribers;

    @Autowired
    public ShoppingListController(
            ShoppingListService shoppingListService,
            DtoTransformer dtoTransformer,
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
                .map(list -> createNewItem(item.getName(), item.getCategory(), list)).map(dtoTransformer::map));
    }

    private ShoppingListItem createNewItem(String name, @Nullable String category, ShoppingList list) {
        ShoppingListItem newItem = new ShoppingListItem(name);
        newItem.setAssignee(category);
        list.addItem(newItem);
        shoppingListService.saveShoppingList(list);
        shoppingListSubscribers.notifyItemsCreated(list, Collections.singletonList(newItem));
        return newItem;
    }

    @Override
    public ResponseEntity<Void> deleteShoppingListItem(String id, String itemId) {
        shoppingListService.getShoppingList(id).ifPresent(list -> deleteItem(itemId, list));
        return ResponseEntity.noContent().build();
    }

    private void deleteItem(String itemId, ShoppingList list) {
        list.deleteItemById(itemId).ifPresent(deletedItem -> {
            shoppingListService.saveShoppingList(list);
            shoppingListSubscribers.notifyItemsDeleted(list, Collections.singletonList(deletedItem));
        });
    }

    @Override
    public ResponseEntity<Void> updateShoppingListItem(String id, String itemId, ShoppingListItemUpdateDto updateItem) {
        return shoppingListService.getShoppingList(id).map(list -> findAndUpdateItem(itemId, updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> findAndUpdateItem(String itemId, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        return list.findItemById(itemId).map(item -> updateItem(item, updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> updateItem(ShoppingListItem item, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        item.setName(updateItem.getName());
        item.setChecked(updateItem.isChecked());
        item.setAssignee(updateItem.getCategory());
        shoppingListService.saveShoppingList(list);
        shoppingListSubscribers.notifyItemsChanged(list, Collections.singletonList(item));
        return ResponseEntity.noContent().build();
    }

}
