package de.hanselmann.shoppinglist.controller;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.Nullable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
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

        final ShoppingListPermissionsDto userPermissions = user.getShoppingListPermissions().stream()
                .filter(listRef -> listRef.getList().getId() == list.getId()).findAny()
                .map(ShoppingListPermission::getRole).map(dtoTransformer::map)
                .orElseThrow(() -> new IllegalArgumentException("User does not know that list."));

        final List<ShoppingListUserReferenceDto> otherUsers = list.getPermissions().stream()
                .filter(userRef -> userRef.getUserId() != user.getId())
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
    public ResponseEntity<Void> deleteShoppingList(long id) {
        boolean removed = shoppingListService.removeUserFromList(id, userService.getCurrentUser());
        if (removed) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.badRequest().build();
        }
    }

    @PreAuthorize("@shoppingListGuard.canCheckItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> uncheckShoppingListItems(long id, UncheckShoppingListItemsDto dto) {
        return shoppingListService.findShoppingList(id)
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
    public ResponseEntity<Void> removeShoppingListCategory(long id, RemoveShoppingListCategoryDto dto) {
        return shoppingListService.findShoppingList(id)
                .map(list -> removeCategoriesFromShoppingList(list, dto.getCategory().orElse(null)))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> removeCategoriesFromShoppingList(ShoppingList list, @Nullable String category) {
        shoppingListService.removeCategory(list, category);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> renameShoppingListCategory(long id, RenameShoppingListCategoryDto dto) {
        if ((dto.getOldCategory() == null || dto.getOldCategory().isBlank())
                || (dto.getNewCategory() == null || dto.getNewCategory().isBlank())) {
            return ResponseEntity.badRequest().build();
        }
        return shoppingListService.findShoppingList(id)
                .map(list -> renameShoppingListCategory(list, dto.getOldCategory(), dto.getNewCategory()))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> renameShoppingListCategory(ShoppingList list, String oldCategory, String newCategory) {
        shoppingListService.renameCategory(list, oldCategory, newCategory);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> clearShoppingList(long id) {
        return shoppingListService.findShoppingList(id).map(this::clearShoppingList)
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> clearShoppingList(ShoppingList list) {
        shoppingListService.removeAllItems(list);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> moveShoppingListItem(long id, MoveShoppingListItemDto moveItem) {
        return shoppingListService.findShoppingList(id)
                .map(list -> moveShoppingListItem(list, moveItem.getItemId(), moveItem.getTargetIndex()))
                .orElse(ResponseEntity.badRequest().build());
    }

    private ResponseEntity<Void> moveShoppingListItem(ShoppingList list, long itemId, int targetIndex) {
        return list.findItemById(itemId)
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
    public ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(long id) {
        return ResponseEntity.of(shoppingListService.findShoppingList(id).map(ShoppingList::getItems)
                .map(dtoTransformer::map));
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListItemDto> addShoppingListItem(long id, NewShoppingListItemDto item) {
        return ResponseEntity.of(shoppingListService.findShoppingList(id)
                .map(list -> createNewItem(item, list)).map(dtoTransformer::map));
    }

    private ShoppingListItem createNewItem(NewShoppingListItemDto item, ShoppingList list) {
        return shoppingListService.createNewItem(item.getName(), item.getCategory(), list);
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> deleteShoppingListItem(long id, long itemId) {
        shoppingListService.findShoppingList(id).ifPresent(list -> deleteItem(itemId, list));
        return ResponseEntity.noContent().build();
    }

    private void deleteItem(long itemId, ShoppingList list) {
        list.deleteItemById(itemId).ifPresent(deletedItem -> shoppingListService.saveShoppingList(list));
    }

    @PreAuthorize("@shoppingListGuard.canEditItemsInShoppingList(#id)")
    @Override
    public ResponseEntity<Void> deleteShoppingListItems(long id, DeleteItemDto deleteItemDto) {
        shoppingListService.findShoppingList(id)
                .ifPresent(list -> deleteItems(list, deleteItemDto.getOfCategory().orElse(null)));
        return ResponseEntity.noContent().build();
    }

    private void deleteItems(ShoppingList list, @Nullable String ofCategory) {
        list.deleteItemIf(item -> item.isChecked() && (ofCategory == null || ofCategory.equals(item.getCategory())));
        shoppingListService.saveShoppingList(list);
    }

    @PreAuthorize("@shoppingListGuard.canAccessShoppingList(#id)")
    @Override
    public ResponseEntity<Void> updateShoppingListItem(long id, long itemId, ShoppingListItemUpdateDto updateItem) {
        return shoppingListService.findShoppingList(id)
                .map(list -> findAndUpdateItem(itemId, updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> findAndUpdateItem(long itemId, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        return list.findItemById(itemId).map(item -> updateItem(item, updateItem, list))
                .orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<Void> updateItem(ShoppingListItem item, ShoppingListItemUpdateDto updateItem,
            ShoppingList list) {
        boolean nameChanged = Objects.equals(updateItem.getName(), item.getName());
        boolean categoryChanged = Objects.equals(updateItem.getCategory(), item.getCategory());
        boolean checkedStateChanged = Objects.equals(updateItem.isChecked(), item.isChecked());

        if ((nameChanged || categoryChanged) && !guard.canEditItemsInShoppingList(list.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        if (checkedStateChanged && !guard.canCheckItemsInShoppingList(list.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        item.setName(updateItem.getName());
        item.setChecked(updateItem.isChecked());
        item.setCategory(updateItem.getCategory());

        shoppingListService.saveShoppingList(list);
        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(long id,
            AddUserToShoppingListDto addUserDto) {
        return userService.findByEmailAddress(addUserDto.getEmailAddress())
                .map(user -> addUserToShoppingList(user, id)).orElse(ResponseEntity.notFound().build());
    }

    private ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(ShoppingListUser user,
            long shoppingListId) {
        if (shoppingListService.addUserToShoppingList(shoppingListId, user)) {
            return ResponseEntity.ok(dtoTransformer.map(user, shoppingListId));
        }
        return ResponseEntity.badRequest().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<Void> removeUserFromShoppingList(long shoppingListId, long userId) {
        ShoppingListUser userToBeRemoved = userService.getUser(userId);

        if (userService.getRoleForUser(userToBeRemoved, shoppingListId) == ShoppingListRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        if (!userService.removeShoppingListFromUser(userToBeRemoved, shoppingListId)) {
            return ResponseEntity.badRequest().build();
        }

        shoppingListService.removeUserFromShoppingList(shoppingListId, userToBeRemoved.getId());

        return ResponseEntity.noContent().build();
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<ShoppingListUserReferenceDto> changeShoppingListPermissionsForUser(long shopingListId,
            ShoppingListPermissionsUpdateDto permissionsDto) {
        ShoppingListUser userToBeChanged = userService.getUser(permissionsDto.getUserId());
        if (userService.getRoleForUser(userToBeChanged, shopingListId) == ShoppingListRole.ADMIN) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        userService.changePermission(userToBeChanged, shopingListId, permissionsDto.getRole());
        return ResponseEntity.ok(dtoTransformer.map(userToBeChanged, shopingListId));
    }

    @PreAuthorize("@shoppingListGuard.canEditShoppingList(#id)")
    @Override
    public ResponseEntity<Void> changeShoppingListName(long id, ShoppingListNameUpdateDto shoppingListNameUpdateDto) {
        String name = shoppingListNameUpdateDto.getName().trim();
        if (name.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        shoppingListService.renameList(id, name);
        return ResponseEntity.noContent().build();
    }

}
