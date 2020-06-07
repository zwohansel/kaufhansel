package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListStatusDto;

public interface ShoppingListStatusApi {

    @GetMapping("/status")
    ResponseEntity<ShoppingListStatusDto> getStatus();

}
