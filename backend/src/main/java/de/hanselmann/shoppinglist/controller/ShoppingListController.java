package de.hanselmann.shoppinglist.controller;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.ShoppingListService;
import de.hanselmann.shoppinglist.service.ShoppingListSubscribers;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@PreAuthorize("hasRole('SHOPPER')")
@RestController
public class ShoppingListController implements ShoppingListApi {
    private final ShoppingListService shoppingListService;
    private final ShoppingListUserService userService;
    private final DtoTransformer dtoTransformer;
    private final ShoppingListSubscribers shoppingListSubscribers;

    @Autowired
    public ShoppingListController(
            ShoppingListService shoppingListService,
            ShoppingListUserService userService,
            DtoTransformer dtoTransformer,
            ShoppingListSubscribers shoppingListSubscribers) {
        this.shoppingListService = shoppingListService;
        this.userService = userService;
        this.dtoTransformer = dtoTransformer;
        this.shoppingListSubscribers = shoppingListSubscribers;
    }

    @Override
    public ResponseEntity<Void> login() {
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<List<ShoppingListInfoDto>> getShoppingLists() {
        final List<ShoppingListInfoDto> infos = shoppingListService.getShoppingListsOfCurrentUser()
                .map(list -> new ShoppingListInfoDto(list.getId().toString(), list.getName(),
                        getShoppingListUserReferenceDtos(list)))
                .collect(Collectors.toList());
        return ResponseEntity.ok(infos);
    }

    @Override
    public ResponseEntity<ShoppingListInfoDto> createShoppingList(NewShoppingListDto newList) {
        ShoppingList newShoppingList = shoppingListService.createShoppingListForCurrentUser(newList.getName());

        if (newShoppingList == null) {
            return ResponseEntity.badRequest().build();
        }

        return ResponseEntity
                .ok(new ShoppingListInfoDto(newShoppingList.getId().toString(),
                        newShoppingList.getName(),
                        getShoppingListUserReferenceDtos(newShoppingList)));
    }

    private List<ShoppingListUserReferenceDto> getShoppingListUserReferenceDtos(ShoppingList shoppingList) {
        return shoppingList.getUsers().stream()
                .map(userRef -> userService.getUser(userRef.getUserId()))
                .map(dtoTransformer::map)
                .collect(Collectors.toList());
    }

    @Override
    public ResponseEntity<Void> deleteShoppingList(String id) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        boolean deleted = shoppingListService.deleteShoppingList(new ObjectId(id));
        if (deleted) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.badRequest().build();
        }
    }

    @Override
    public ResponseEntity<Void> uncheckAllShoppingListItems(String id) {
        return shoppingListService.getShoppingList(new ObjectId(id))
                .map(this::uncheckAllShoppingListItems)
                .orElse(ResponseEntity.noContent().build());
    }

    private ResponseEntity<Void> uncheckAllShoppingListItems(ShoppingList list) {
        List<ShoppingListItem> changedItems = shoppingListService.uncheckAllItems(list);
        if (changedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListSubscribers.notifyItemsChanged(list, changedItems);
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<Void> removeAllCategoriesFromShoppingList(String id) {
        return shoppingListService.getShoppingList(new ObjectId(id))
                .map(this::removeAllCategoriesFromShoppingList)
                .orElse(ResponseEntity.noContent().build());
    }

    private ResponseEntity<Void> removeAllCategoriesFromShoppingList(ShoppingList list) {
        List<ShoppingListItem> changedItems = shoppingListService.removeAllCategories(list);
        if (changedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListSubscribers.notifyItemsChanged(list, changedItems);
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<Void> clearShoppingList(String id) {
        return shoppingListService.getShoppingList(new ObjectId(id))
                .map(this::clearShoppingList)
                .orElse(ResponseEntity.noContent().build());
    }

    private ResponseEntity<Void> clearShoppingList(ShoppingList list) {
        List<ShoppingListItem> deletedItems = shoppingListService.removeAllItems(list);
        if (deletedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListSubscribers.notifyItemsDeleted(list, deletedItems);
        return ResponseEntity.noContent().build();
    }

    @Override
    public ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(String id) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity
                .of(shoppingListService.getShoppingList(new ObjectId(id)).map(ShoppingList::getItems)
                        .map(dtoTransformer::map));
    }

    @Override
    public ResponseEntity<ShoppingListItemDto> addShoppingListItem(String id, NewShoppingListItemDto item) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.of(shoppingListService.getShoppingList(new ObjectId(id))
                .map(list -> createNewItem(item, list))
                .map(dtoTransformer::map));
    }

    private ShoppingListItem createNewItem(NewShoppingListItemDto item, ShoppingList list) {
        ShoppingListItem newItem = shoppingListService.createNewItem(item.getName(), item.getCategory(), list);
        shoppingListSubscribers.notifyItemsCreated(list, Collections.singletonList(newItem));
        return newItem;
    }

    @Override
    public ResponseEntity<Void> deleteShoppingListItem(String id, String itemId) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListService.getShoppingList(new ObjectId(id)).ifPresent(list -> deleteItem(itemId, list));
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
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.getShoppingList(new ObjectId(id))
                .map(list -> findAndUpdateItem(itemId, updateItem, list))
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
