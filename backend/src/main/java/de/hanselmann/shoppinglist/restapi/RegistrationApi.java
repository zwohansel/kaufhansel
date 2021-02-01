package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;

public interface RegistrationApi {

    @PostMapping("/register")
    ResponseEntity<RegistrationResultDto> register(
            @RequestBody RegistrationDataDto registrationData);

}
