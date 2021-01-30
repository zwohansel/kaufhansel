package de.hanselmann.shoppinglist.restapi;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import de.hanselmann.shoppinglist.restapi.dto.AddUserToShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.MoveShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListNameUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;

public interface ShoppingListApi {

    // TODO: move to some kind of UserApi
    @GetMapping("/user")
    ResponseEntity<ShoppingListUserInfoDto> getUserInfo();

    @GetMapping("/shoppinglists")
    ResponseEntity<List<ShoppingListInfoDto>> getShoppingLists();

    @PostMapping("/shoppinglist")
    ResponseEntity<ShoppingListInfoDto> createShoppingList(
            @RequestBody NewShoppingListDto newList);

    @DeleteMapping("/shoppinglist/{id}")
    ResponseEntity<Void> deleteShoppingList(
            @PathVariable String id);

    @GetMapping("/shoppinglist/{id}")
    ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(
            @PathVariable String id);

    @PostMapping("/shoppinglist/{id}/uncheckallitems")
    ResponseEntity<Void> uncheckAllShoppingListItems(
            @PathVariable String id);

    @PostMapping("/shoppinglist/{id}/removeallcategories")
    ResponseEntity<Void> removeAllCategoriesFromShoppingList(
            @PathVariable String id);

    @PostMapping("/shoppinglist/{id}/clear")
    ResponseEntity<Void> clearShoppingList(
            @PathVariable String id);

    @PutMapping("/shoppinglist/{id}/moveitem")
    ResponseEntity<Void> moveShoppingListItem(
            @PathVariable String id,
            @RequestBody MoveShoppingListItemDto moveItem);

    @PostMapping("/shoppinglist/{id}")
    ResponseEntity<ShoppingListItemDto> addShoppingListItem(
            @PathVariable String id,
            @RequestBody NewShoppingListItemDto item);

    @DeleteMapping("/shoppinglist/{id}/item/{itemId}")
    ResponseEntity<Void> deleteShoppingListItem(
            @PathVariable String id,
            @PathVariable String itemId);

    @PutMapping("/shoppinglist/{id}/item/{itemId}")
    ResponseEntity<Void> updateShoppingListItem(
            @PathVariable String id,
            @PathVariable String itemId,
            @RequestBody ShoppingListItemUpdateDto updateItem);

    @PutMapping("/shoppinglist/{id}/user")
    ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(
            @PathVariable String id,
            @RequestBody AddUserToShoppingListDto addUserDto);

    @DeleteMapping("/shoppinglist/{id}/user/{userId}")
    ResponseEntity<Void> removeUserFromShoppingList(
            @PathVariable String id,
            @PathVariable String userId);

    @PutMapping("/shoppinglist/{id}/permissions")
    ResponseEntity<ShoppingListUserReferenceDto> changeShoppingListPermissionsForUser(
            @PathVariable String id,
            @RequestBody ShoppingListPermissionsUpdateDto permissionsDto);

    @PutMapping("/shoppinglist/{id}/name")
    ResponseEntity<Void> changeShoppingListName(
            @PathVariable String id,
            @RequestBody ShoppingListNameUpdateDto shoppingListNameUpdateDto);
}
