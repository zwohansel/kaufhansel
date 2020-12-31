package de.hanselmann.shoppinglist.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.restapi.ShoppingListApi;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.ShoppingListService;

@RestController
public class ShoppingListController implements ShoppingListApi {
	private final ShoppingListService shoppingListService;
	private final DtoTransformer dtoTransformer;

	@Autowired
	public ShoppingListController(ShoppingListService shoppingListService, DtoTransformer dtoTransformer) {
		this.shoppingListService = shoppingListService;
		this.dtoTransformer = dtoTransformer;
	}

	@Override
	public ResponseEntity<List<ShoppingListItemDto>> getShoppingListItems(String id) {
		return ResponseEntity.of(shoppingListService.getShoppingList(id).map(ShoppingList::getItems).map(dtoTransformer::map));
	}

}
