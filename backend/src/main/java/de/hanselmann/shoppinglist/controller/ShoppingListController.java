package de.hanselmann.shoppinglist.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListItem;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.service.ShoppingListService;

@RestController
public class ShoppingListController implements ShoppingListApi {
	private final ShoppingListService shoppingListService;
	
	@Autowired
	public ShoppingListController(ShoppingListService shoppingListService) {
		this.shoppingListService = shoppingListService;
	}

	@Override
	public ResponseEntity<List<ShoppingListItem>> getShoppingListItems(String id) {
		return ResponseEntity.of(shoppingListService.getShoppingList(id).map(ShoppingList::getItems));
	}

}
