package de.hanselmann.shoppinglist.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import de.hanselmann.shoppinglist.restapi.dto.LoginDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.RequestUserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.SendListInviteDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.UserPasswordResetDto;

@RequestMapping("/api/user")
public interface UserApi {

    @PostMapping("/login")
    ResponseEntity<ShoppingListUserInfoDto> login(
            @RequestBody LoginDto loginDto);

    @PostMapping("/register")
    ResponseEntity<RegistrationResultDto> register(
            @RequestBody RegistrationDataDto registrationData);

    @GetMapping("/activate/{activationCode}")
    ResponseEntity<Void> activate(
            @PathVariable String activationCode);

    @PostMapping("/invite")
    ResponseEntity<Void> sendListInvite(
            @RequestBody SendListInviteDto sendInvite);

    @PostMapping("/password/requestreset")
    ResponseEntity<Void> requestUserPasswordResetCode(
            @RequestBody RequestUserPasswordResetDto requestUserPasswordReset);

    @PostMapping("/password/reset")
    ResponseEntity<Void> resetUserPassword(
            @RequestBody UserPasswordResetDto userPasswordReset);

    @DeleteMapping("/{userToBeDeletedId}")
    ResponseEntity<Void> deleteUser(
            @PathVariable long userToBeDeletedId);
}
