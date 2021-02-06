package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;

import de.hanselmann.shoppinglist.restapi.dto.InfoDto;

public interface InfoApi {

    @GetMapping("/info")
    public ResponseEntity<InfoDto> getInfo();

}
