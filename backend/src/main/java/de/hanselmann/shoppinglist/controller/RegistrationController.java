package de.hanselmann.shoppinglist.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.restapi.RegistrationApi;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.service.RegistrationService;

@RestController
public class RegistrationController implements RegistrationApi {
    private final RegistrationService registrationService;

    @Autowired
    public RegistrationController(RegistrationService registrationService) {
        this.registrationService = registrationService;
    }

    @Override
    public ResponseEntity<RegistrationResultDto> register(RegistrationDataDto registrationData) {
        if (!registrationService.isInviteCodeValid(registrationData.getInviteCode())) {
            return ResponseEntity.ok(RegistrationResultDto.inviteCodeInvalid());
        }

        if (!registrationService.isEmailAddressValid(registrationData.getEmailAddress())) {
            return ResponseEntity.ok(RegistrationResultDto.emailInvalid());
        }

        if (!registrationService.isPasswordValid(registrationData.getPassword())) {
            return ResponseEntity.ok(RegistrationResultDto.passwordInvalid());
        }

        if (registrationService.registerUser(registrationData.getEmailAddress(), registrationData.getUserName(),
                registrationData.getPassword())) {
            return ResponseEntity.ok(RegistrationResultDto.success());
        } else {
            return ResponseEntity.ok(RegistrationResultDto.fail());
        }
    }

}
