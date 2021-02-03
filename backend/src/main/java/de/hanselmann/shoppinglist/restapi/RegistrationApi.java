package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import de.hanselmann.shoppinglist.restapi.dto.InviteCodeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;

public interface RegistrationApi {

    @PostMapping("/register")
    ResponseEntity<RegistrationResultDto> register(
            @RequestBody RegistrationDataDto registrationData);

    @GetMapping("/activate/{activationCode}")
    ResponseEntity<String> activate(@PathVariable String activationCode);

    @GetMapping("/invite")
    ResponseEntity<InviteCodeDto> generateInvite();

}
