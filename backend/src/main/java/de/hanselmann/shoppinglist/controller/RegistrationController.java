package de.hanselmann.shoppinglist.controller;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.restapi.RegistrationApi;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.service.RegistrationService;

@RestController
public class RegistrationController implements RegistrationApi {
    private final RegistrationService registrationService;
    private final String activationSuccessPage;
    private final String activationFailurePage;

    @Autowired
    public RegistrationController(RegistrationService registrationService, ResourceLoader resourceLoader)
            throws IOException {
        this.registrationService = registrationService;
        try (InputStream in = resourceLoader.getResource("classpath:static/activation_success.html").getInputStream()) {
            this.activationSuccessPage = new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
        try (InputStream in = resourceLoader.getResource("classpath:static/activation_failure.html").getInputStream()) {
            this.activationFailurePage = new String(in.readAllBytes(), StandardCharsets.UTF_8);
        }
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

    @Override
    public ResponseEntity<String> activate(String activationCode) {
        if (registrationService.activate(activationCode)) {
            return ResponseEntity.ok(activationSuccessPage);
        }
        return ResponseEntity.ok(activationFailurePage);
    }

}
