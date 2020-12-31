package de.hanselmann.shoppinglist.restapi;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;

public interface ShoppingListApi {
	
	@GetMapping("/shoppinglist/{id}")
	ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(@PathVariable String id);

}
