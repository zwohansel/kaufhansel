package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import de.hanselmann.shoppinglist.restapi.dto.InviteCodeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationProcessTypeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.RequestUserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.SendInviteDto;
import de.hanselmann.shoppinglist.restapi.dto.UserPasswordResetDto;

public interface UserApi {

    @PostMapping("/register")
    ResponseEntity<RegistrationResultDto> register(
            @RequestBody RegistrationDataDto registrationData);

    @GetMapping("/register/type/{inviteCode}")
    ResponseEntity<RegistrationProcessTypeDto> getRegistrationProcessType(
            @PathVariable String inviteCode);

    @GetMapping("/activate/{activationCode}")
    ResponseEntity<String> activate(
            @PathVariable String activationCode);

    @GetMapping("/invite")
    ResponseEntity<InviteCodeDto> generateInvite();

    @PostMapping("/invite")
    ResponseEntity<Void> sendInvite(
            @RequestBody SendInviteDto sendInvite);

    @PostMapping("/user/requestpasswordreset")
    ResponseEntity<Void> requestUserPasswordResetCode(
            @RequestBody RequestUserPasswordResetDto requestUserPasswordReset);

    @PostMapping("/user/passwordreset")
    ResponseEntity<Void> resetUserPassword(
            @RequestBody UserPasswordResetDto userPasswordReset);
}