package de.hanselmann.shoppinglist.controller;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.AddUserToShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.DeleteItemDto;
import de.hanselmann.shoppinglist.restapi.dto.MoveShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.RemoveShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.RenameShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListNameUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;
import de.hanselmann.shoppinglist.restapi.dto.UncheckShoppingListItemsDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.ShoppingListService;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@PreAuthorize("hasRole('SHOPPER')")
@RestController
public class ShoppingListController implements ShoppingListApi {
    private final ShoppingListService shoppingListService;
    private final ShoppingListUserService userService;
    private final ShoppingListGuard guard;
    private final DtoTransformer dtoTransformer;

    @Autowired
    public ShoppingListController(ShoppingListService shoppingListService, ShoppingListUserService userService,
            ShoppingListGuard guard, DtoTransformer dtoTransformer) {
        this.shoppingListService = shoppingListService;
        this.userService = userService;
        this.guard = guard;
        this.dtoTransformer = dtoTransformer;
    }

    @Override
    public ResponseEntity<List<ShoppingListInfoDto>> getShoppingLists() {
        final List<ShoppingListInfoDto> infos = shoppingListService.getShoppingListsOfCurrentUser().map(this::toInfo)
                .collect(Collectors.toList());
        return ResponseEntity.ok(infos);
    }

    private ShoppingListInfoDto toInfo(ShoppingList list) {
        final ShoppingListUser user = userService.getCurrentUser();

        final ShoppingListPermissionsDto userPermissions = user.getShoppingLists().stream()
                .filter(listRef -> listRef.getShoppingListId().equals(list.getId())).findAny()
                .map(ShoppingListReference::getRole).map(dtoTransformer::map)
                .orElseThrow(() -> new IllegalArgumentException("User does not know that list."));

        final List<ShoppingListUserReferenceDto> otherUsers = list.getUsers().stream()
                .filter(userRef -> !userRef.getUserId().equals(user.getId()))
                .map(userRef -> userService.getUser(userRef.getUserId()))
                .map(otherUser -> dtoTransformer.map(otherUser, list.getId())).collect(Collectors.toList());

        return dtoTransformer.map(list, userPermissions, otherUsers);
    }

    @Override
    public ResponseEntity<ShoppingListInfoDto> createShoppingList(NewShoppingListDto newList) {
        ShoppingList newShoppingList = shoppingListService.createShoppingListForCurrentUser(newList.getName());

        if (newShoppingList == null) {
            return ResponseEntity.badRequest().build();
        }

        return ResponseEntity.ok(toInfo(newShoppingList));
    }

    @PreAuthorize("@shoppingListGuard.canAccessShoppingList(#id)")
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

    @PreAuthorize("@shoppingListGuard.canCheckItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> uncheckShoppingListItems(String id, UncheckShoppingListItemsDto dto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }

        return shoppingListService.findShoppingList(new ObjectId(id))
                .map(item -> uncheckAllShoppingListItems(item, dto.getCategory().orElse(null)))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> uncheckAllShoppingListItems(ShoppingList list, @Nullable String category) {
        List<ShoppingListItem> changedItems = shoppingListService.uncheckItems(list, category);
        if (changedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> removeShoppingListCategory(String id, RemoveShoppingListCategoryDto dto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(new ObjectId(id))
                .map(list -> removeCategoriesFromShoppingList(list, dto.getCategory().orElse(null)))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> removeCategoriesFromShoppingList(ShoppingList list, @Nullable String category) {
        List<ShoppingListItem> changedItems = shoppingListService.removeCategory(list, category);
        if (changedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> renameShoppingListCategory(String id, RenameShoppingListCategoryDto dto) {
        if (!ObjectId.isValid(id)
                || (dto.getOldCategory() == null || dto.getOldCategory().isBlank())
                || (dto.getNewCategory() == null || dto.getNewCategory().isBlank())) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(new ObjectId(id))
                .map(list -> renameShoppingListCategory(list, dto.getOldCategory(), dto.getNewCategory()))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> renameShoppingListCategory(ShoppingList list, String oldCategory, String newCategory) {
        List<ShoppingListItem> changedItems = shoppingListService.renameCategory(list, oldCategory, newCategory);
        if (changedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> clearShoppingList(String id) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(new ObjectId(id)).map(this::clearShoppingList)
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> clearShoppingList(ShoppingList list) {
        List<ShoppingListItem> deletedItems = shoppingListService.removeAllItems(list);
        if (deletedItems == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> moveShoppingListItem(String id, MoveShoppingListItemDto moveItem) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(new ObjectId(id))
                .map(list -> moveShoppingListItem(list, moveItem.getItemId(), moveItem.getTargetIndex()))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> moveShoppingListItem(ShoppingList list, String id, int targetIndex) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return list.findItemById(new ObjectId(id))
                .map(item -> moveShoppingListItem(list, item, targetIndex))
                .orElse(ResponseEntity.badRequest().<Void>build());
    }

    private ResponseEntity<Void> moveShoppingListItem(ShoppingList list, ShoppingListItem item, int targetIndex) {
        if (targetIndex < 0) {
            return ResponseEntity.badRequest().build();
        }
        if (shoppingListService.moveShoppingListItem(list, item, targetIndex)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.badRequest().build();
    }

    @PreAuthorize("@shoppingListGuard.canAccessShoppingList(#id)")
    @Override
    public ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(String id) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.of(shoppingListService.findShoppingList(new ObjectId(id)).map(ShoppingList::getItems)
                .map(dtoTransformer::map));
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListItemDto> addShoppingListItem(String id, NewShoppingListItemDto item) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.of(shoppingListService.findShoppingList(new ObjectId(id))
                .map(list -> createNewItem(item, list)).map(dtoTransformer::map));
    }

    private ShoppingListItem createNewItem(NewShoppingListItemDto item, ShoppingList list) {
        return shoppingListService.createNewItem(item.getName(), item.getCategory(), list);
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> deleteShoppingListItem(String id, String itemId) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListService.findShoppingList(new ObjectId(id)).ifPresent(list -> deleteItem(itemId, list));
        return ResponseEntity.noContent().build();
    }

    private void deleteItem(String itemId, ShoppingList list) {
        if (!ObjectId.isValid(itemId)) {
            return;
        }
        list.deleteItemById(new ObjectId(itemId)).ifPresent(deletedItem -> shoppingListService.saveShoppingList(list));
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> deleteShoppingListItems(String id, DeleteItemDto deleteItemDto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListService.findShoppingList(new ObjectId(id))
                .ifPresent(list -> deleteItems(list, deleteItemDto.getOfCategory().orElse(null)));
        return ResponseEntity.noContent().build();
    }

    private void deleteItems(ShoppingList list, @Nullable String ofCategory) {
        list.deleteItemIf(item -> item.isChecked() && (ofCategory == null || ofCategory.equals(item.getAssignee())));
        shoppingListService.saveShoppingList(list);
    }

    @PreAuthorize("@shoppingListGuard.canAccessShoppingList(#id)")
    @Override
    public ResponseEntity<Void> updateShoppingListItem(String id, String itemId, ShoppingListItemUpdateDto updateItem) {
        if (!ObjectId.isValid(id) || !ObjectId.isValid(itemId)) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(new ObjectId(id))
                .map(list -> findAndUpdateItem(new ObjectId(itemId), updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> findAndUpdateItem(ObjectId itemId, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        return list.findItemById(itemId).map(item -> updateItem(item, updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> updateItem(ShoppingListItem item, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        boolean nameChanged = Objects.equals(updateItem.getName(), item.getName());
        boolean categoryChanged = Objects.equals(updateItem.getCategory(), item.getAssignee());
        boolean checkedStateChanged = Objects.equals(updateItem.isChecked(), item.isChecked());

        if ((nameChanged || categoryChanged) && !guard.canEditItemsInShoppingList(list.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        if (checkedStateChanged && !guard.canCheckItemsInShoppingList(list.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        item.setName(updateItem.getName());
        item.setChecked(updateItem.isChecked());
        item.setAssignee(updateItem.getCategory());

        shoppingListService.saveShoppingList(list);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(String id,
            AddUserToShoppingListDto addUserDto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }

        return userService.findByEmailAddress(addUserDto.getEmailAddress())
                .map(user -> addUserToShoppingList(user, new ObjectId(id))).orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(ShoppingListUser user,
            ObjectId shoppingListId) {
        if (shoppingListService.addUserToShoppingList(shoppingListId, user)) {
            return ResponseEntity.ok(dtoTransformer.map(user, shoppingListId));
        }
        return ResponseEntity.badRequest().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<Void> removeUserFromShoppingList(String id, String userId) {
        if (!ObjectId.isValid(id) || !ObjectId.isValid(userId)) {
            return ResponseEntity.badRequest().build();
        }
        ObjectId shoppingListObjectId = new ObjectId(id);

        ShoppingListUser userToBeRemoved = userService.getUser(new ObjectId(userId));

        if (userService.getRoleForUser(userToBeRemoved, shoppingListObjectId) == ShoppingListRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        if (!userService.removeShoppingListFromUser(userToBeRemoved, shoppingListObjectId)) {
            return ResponseEntity.badRequest().build();
        }

        shoppingListService.removeUserFromShoppingList(shoppingListObjectId, userToBeRemoved.getId());

        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListUserReferenceDto> changeShoppingListPermissionsForUser(String id,
            ShoppingListPermissionsUpdateDto permissionsDto) {
        if (!ObjectId.isValid(id) || !ObjectId.isValid(permissionsDto.getUserId())) {
            return ResponseEntity.badRequest().build();
        }
        ObjectId shopingListId = new ObjectId(id);

        ShoppingListUser userToBeChanged = userService.getUser(new ObjectId(permissionsDto.getUserId()));
        if (userService.getRoleForUser(userToBeChanged, shopingListId) == ShoppingListRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        userService.changePermission(userToBeChanged, shopingListId, permissionsDto.getRole());
        return ResponseEntity.ok(dtoTransformer.map(userToBeChanged, shopingListId));
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<Void> changeShoppingListName(String id, ShoppingListNameUpdateDto shoppingListNameUpdateDto) {
        if (!ObjectId.isValid(id)) {
            return ResponseEntity.badRequest().build();
        }
        String name = shoppingListNameUpdateDto.getName().trim();
        if (name.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListService.renameList(new ObjectId(id), name);
        return ResponseEntity.noContent().build();
    }

}
