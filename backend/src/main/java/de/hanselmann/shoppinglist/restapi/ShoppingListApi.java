package de.hanselmann.shoppinglist.restapi;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;

public interface ShoppingListApi {

    @GetMapping("/shoppinglist/{id}")
    ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(@PathVariable String id);

    @PostMapping("/shoppinglist/{id}")
    ResponseEntity<ShoppingListItemDto> addShoppingListItem(@PathVariable String id,
            @RequestBody NewShoppingListItemDto item);

    @DeleteMapping("/shoppinglist/{id}/item/{itemId}")
    ResponseEntity<Void> deleteShoppingListItem(@PathVariable String id, @PathVariable String itemId);

}
