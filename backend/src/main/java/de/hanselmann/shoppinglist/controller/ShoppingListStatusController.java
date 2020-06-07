package de.hanselmann.shoppinglist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.restapi.ShoppingListStatusApi;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListStatusDto;
import de.hanselmann.shoppinglist.service.ShoppingListStatusService;

@RestController
public class ShoppingListStatusController implements ShoppingListStatusApi {

    private final ShoppingListStatusService statusService;

    @Autowired
    public ShoppingListStatusController(ShoppingListStatusService statusService) {
        this.statusService = statusService;
    }

    @Override
    public ResponseEntity<ShoppingListStatusDto> getStatus() {
        int numberOfOpenItems = statusService.getNumberOfOpenItems();
        ShoppingListStatusDto status = new ShoppingListStatusDto(numberOfOpenItems);
        return ResponseEntity.ok(status);
    }

}
