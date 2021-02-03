package de.hanselmann.shoppinglist.controller;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.restapi.RegistrationApi;
import de.hanselmann.shoppinglist.restapi.dto.InviteCodeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.SendInviteDto;
import de.hanselmann.shoppinglist.service.RegistrationService;

@RestController
public class RegistrationController implements RegistrationApi {
    private final RegistrationService registrationService;
    private final ShoppingListGuard guard;
    private final String activationSuccessPage;
    private final String activationFailurePage;

    @Autowired
    public RegistrationController(RegistrationService registrationService, ShoppingListGuard guard,
            ResourceLoader resourceLoader)
            throws IOException {
        this.registrationService = registrationService;
        this.guard = guard;
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

    @PreAuthorize("hasRole('SHOPPER')")
    @Override
    public ResponseEntity<InviteCodeDto> generateInvite() {
        String code = registrationService.generateInviteCode();
        return ResponseEntity.ok(new InviteCodeDto(code));
    }

    @PreAuthorize("hasRole('SHOPPER')")
    @Override
    public ResponseEntity<Void> sendInvite(SendInviteDto sendInvite) {
        try {
            if (sendInvite.getShoppingListId().isPresent()) {
                String shoppingListId = sendInvite.getShoppingListId().get();
                if (!guard.canEditShoppingList(shoppingListId)) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
                registrationService.sendInviteForShoppingList(sendInvite.getEmailAddress(),
                        new ObjectId(shoppingListId));
            } else {
                registrationService.sendInvite(sendInvite.getEmailAddress());
            }
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
