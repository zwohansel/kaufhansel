package de.hanselmann.shoppinglist.controller;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.AddUserToShoppingListDto;
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

    @Override
    public ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(String id,
            AddUserToShoppingListDto addUserDto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }

        Optional<ShoppingListUser> userOptional = userService.findByEmailAddress(addUserDto.getEmailAddress());
        if (userOptional.isPresent()) {
            shoppingListService.addUserToShoppingList(new ObjectId(id), userOptional.get());
            return ResponseEntity.ok(dtoTransformer.map(userOptional.get()));
        } else {
            return ResponseEntity.badRequest().build();
        }
    }

}
