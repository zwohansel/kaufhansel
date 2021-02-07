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

import de.hanselmann.shoppinglist.restapi.UserApi;
import de.hanselmann.shoppinglist.restapi.dto.InviteCodeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationProcessTypeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.RequestUserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.SendInviteDto;
import de.hanselmann.shoppinglist.restapi.dto.UserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.service.RegistrationService;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@RestController
public class UserController implements UserApi {
    private final RegistrationService registrationService;
    private final ShoppingListUserService userService;
    private final ShoppingListGuard guard;
    private final DtoTransformer dtoTransformer;
    private final String activationSuccessPage;
    private final String activationFailurePage;

    @Autowired
    public UserController(RegistrationService registrationService,
            ShoppingListUserService userService,
            ShoppingListGuard guard,
            DtoTransformer dtoTransformer,
            ResourceLoader resourceLoader)
            throws IOException {
        this.registrationService = registrationService;
        this.userService = userService;
        this.guard = guard;
        this.dtoTransformer = dtoTransformer;
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

        String emailAddress = registrationData.getEmailAddress().orElse(null);

        if (emailAddress != null && !registrationService.isEmailAddressUnused(emailAddress)) {
            return ResponseEntity.ok(RegistrationResultDto.emailInvalid());
        }

        if (!registrationService.isPasswordValid(registrationData.getPassword())) {
            return ResponseEntity.ok(RegistrationResultDto.passwordInvalid());
        }

        boolean success;
        if (emailAddress == null) {
            success = registrationService.registerUserWithEMailAddressFromInvite(
                    registrationData.getInviteCode(),
                    registrationData.getUserName(),
                    registrationData.getPassword());
        } else {
            success = registrationService.registerUser(
                    registrationData.getInviteCode(),
                    emailAddress,
                    registrationData.getUserName(),
                    registrationData.getPassword());
        }

        if (success) {
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
            boolean success = false;
            if (sendInvite.getShoppingListId().isPresent()) {
                String shoppingListId = sendInvite.getShoppingListId().get();
                if (!guard.canEditShoppingList(shoppingListId)) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
                success = registrationService.sendInviteForShoppingList(sendInvite.getEmailAddress(),
                        new ObjectId(shoppingListId));
            } else {
                success = registrationService.sendInvite(sendInvite.getEmailAddress());
            }
            return success ? ResponseEntity.noContent().build() : ResponseEntity.badRequest().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Override
    public ResponseEntity<RegistrationProcessTypeDto> getRegistrationProcessType(String inviteCode) {
        return ResponseEntity.ok(dtoTransformer.map(registrationService.getTypeOfRegistrationProcess(inviteCode)));
    }

    @Override
    public ResponseEntity<Void> requestUserPasswordResetCode(RequestUserPasswordResetDto requestUserPasswordReset) {
        try {
            userService.findByEmailAddress(requestUserPasswordReset.getEmailAddress().toLowerCase().strip())
                    .ifPresent(userService::requestPasswordReset);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Override
    public ResponseEntity<Void> resetUserPassword(UserPasswordResetDto userPasswordReset) {
        try {
            boolean success = userService.findByEmailAddress(userPasswordReset.getEmailAddress().toLowerCase().strip())
                    .map(user -> userService.resetPassword(user, userPasswordReset.getResetCode(),
                            userPasswordReset.getPassword()))
                    .orElse(false);
            if (success) {
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.badRequest().build();
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
