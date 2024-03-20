package de.hanselmann.shoppinglist.restapi;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import de.hanselmann.shoppinglist.restapi.dto.AddUserToShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.MoveShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.RemoveShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.RenameShoppingListCategoryDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListNameUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsUpdateDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;
import de.hanselmann.shoppinglist.restapi.dto.UncheckShoppingListItemsDto;

@RequestMapping("/api")
public interface ShoppingListApi {

    @GetMapping("/shoppinglists")
    ResponseEntity<List<ShoppingListInfoDto>> getShoppingLists();

    @PostMapping("/shoppinglist")
    ResponseEntity<ShoppingListInfoDto> createShoppingList(
            @RequestBody NewShoppingListDto newList);

    @DeleteMapping("/shoppinglist/{id}")
    ResponseEntity<Void> deleteShoppingList(
            @PathVariable long id);

    @GetMapping("/shoppinglist/{id}")
    ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(
            @PathVariable long id);

    @PutMapping("/shoppinglist/{id}/uncheckitems")
    ResponseEntity<Void> uncheckShoppingListItems(
            @PathVariable long id,
            @RequestBody UncheckShoppingListItemsDto uncheckShoppingListItemsDto);

    @PutMapping("/shoppinglist/{id}/removecategory")
    ResponseEntity<Void> removeShoppingListCategory(
            @PathVariable long id,
            @RequestBody RemoveShoppingListCategoryDto removeShoppingListCategoryDto);

    @PutMapping("/shoppinglist/{id}/renamecategory")
    ResponseEntity<Void> renameShoppingListCategory(
            @PathVariable long id,
            @RequestBody RenameShoppingListCategoryDto renameShoppingListCategoryDto);

    @PostMapping("/shoppinglist/{id}/clear")
    ResponseEntity<Void> clearShoppingList(
            @PathVariable long id);

    @PutMapping("/shoppinglist/{id}/moveitem")
    ResponseEntity<Void> moveShoppingListItem(
            @PathVariable long id,
            @RequestBody MoveShoppingListItemDto moveItem);

    @PostMapping("/shoppinglist/{id}")
    ResponseEntity<ShoppingListItemDto> addShoppingListItem(
            @PathVariable long id,
            @RequestBody NewShoppingListItemDto item);

    @DeleteMapping("/shoppinglist/{id}/item/{itemId}")
    ResponseEntity<Void> deleteShoppingListItem(
            @PathVariable long id,
            @PathVariable long itemId);

    @PutMapping("/shoppinglist/{id}/item/{itemId}")
    ResponseEntity<Void> updateShoppingListItem(
            @PathVariable long id,
            @PathVariable long itemId,
            @RequestBody ShoppingListItemUpdateDto updateItem);

    @PutMapping("/shoppinglist/{id}/user")
    ResponseEntity<ShoppingListUserReferenceDto> addUserToShoppingList(
            @PathVariable long id,
            @RequestBody AddUserToShoppingListDto addUserDto);

    @DeleteMapping("/shoppinglist/{id}/user/{userId}")
    ResponseEntity<Void> removeUserFromShoppingList(
            @PathVariable long id,
            @PathVariable long userId);

    @PutMapping("/shoppinglist/{id}/permissions")
    ResponseEntity<ShoppingListUserReferenceDto> changeShoppingListPermissionsForUser(
            @PathVariable long id,
            @RequestBody ShoppingListPermissionsUpdateDto permissionsDto);

    @PutMapping("/shoppinglist/{id}/name")
    ResponseEntity<Void> changeShoppingListName(
            @PathVariable long id,
            @RequestBody ShoppingListNameUpdateDto shoppingListNameUpdateDto);
}
