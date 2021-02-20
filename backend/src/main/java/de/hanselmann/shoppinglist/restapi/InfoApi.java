package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import de.hanselmann.shoppinglist.restapi.dto.InfoDto;

@RequestMapping("/api")
public interface InfoApi {

    @GetMapping("/info")
    public ResponseEntity<InfoDto> getInfo();

}
