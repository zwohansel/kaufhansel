package de.hanselmann.shoppinglist.controller;

import java.net.URI;
import java.util.Optional;

import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.RestController;

import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.restapi.UserApi;
import de.hanselmann.shoppinglist.restapi.dto.InviteCodeDto;
import de.hanselmann.shoppinglist.restapi.dto.LoginDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationDataDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationProcessTypeDto;
import de.hanselmann.shoppinglist.restapi.dto.RegistrationResultDto;
import de.hanselmann.shoppinglist.restapi.dto.RequestUserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.SendInviteDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.UserPasswordResetDto;
import de.hanselmann.shoppinglist.restapi.dto.transformer.DtoTransformer;
import de.hanselmann.shoppinglist.security.TokenService;
import de.hanselmann.shoppinglist.service.RegistrationService;
import de.hanselmann.shoppinglist.service.ShoppingListService;
import de.hanselmann.shoppinglist.service.ShoppingListUserService;

@RestController
public class UserController implements UserApi {
    private static final Logger LOGGER = LoggerFactory.getLogger(UserController.class);

    private final RegistrationService registrationService;
    private final ShoppingListUserService userService;
    private final ShoppingListService shoppingListService;
    private final TokenService tokenService;
    private final ShoppingListGuard guard;
    private final PasswordEncoder passwordEncoder;
    private final DtoTransformer dtoTransformer;

    @Autowired
    public UserController(RegistrationService registrationService,
            ShoppingListUserService userService,
            ShoppingListService shoppingListService,
            TokenService tokenService,
            ShoppingListGuard guard,
            PasswordEncoder passwordEncoder,
            DtoTransformer dtoTransformer,
            ResourceLoader resourceLoader) {
        this.registrationService = registrationService;
        this.userService = userService;
        this.shoppingListService = shoppingListService;
        this.tokenService = tokenService;
        this.passwordEncoder = passwordEncoder;
        this.guard = guard;
        this.dtoTransformer = dtoTransformer;
    }

    @Override
    public ResponseEntity<ShoppingListUserInfoDto> login(LoginDto loginDto) {
        return userService.findByEmailAddress(loginDto.getEmailAddress())
                .filter(user -> passwordEncoder.matches(loginDto.getPassword(), user.getPassword()))
                .map(user -> {
                    String token = tokenService.generateToken(user);
                    return ResponseEntity.ok(dtoTransformer.map(user, token));
                }).orElse(ResponseEntity.status(HttpStatus.UNAUTHORIZED).build());
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
    public ResponseEntity<Void> activate(String activationCode) {
        HttpHeaders headers = new HttpHeaders();
        if (registrationService.activate(activationCode)) {
            headers.setLocation(URI.create("/kaufhansel/registration_success.html"));
        } else {
            headers.setLocation(URI.create("/kaufhansel/registration_failure.html"));
        }
        return new ResponseEntity<>(headers, HttpStatus.TEMPORARY_REDIRECT);
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
            final Optional<String> shoppingListId = sendInvite.getShoppingListId();
            if (shoppingListId.isPresent()) {
                if (!guard.canEditShoppingList(shoppingListId.get())) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
                }
                success = registrationService.sendInviteForShoppingList(sendInvite.getEmailAddress(),
                        new ObjectId(shoppingListId.get()));
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

    @PreAuthorize("hasRole('SHOPPER') "
            + "&& @shoppingListGuard.canDeleteUser(#userToBeDeletedId)")
    @Override
    public ResponseEntity<Void> deleteUser(String userToBeDeletedId) {
        String currentUser = userService.getCurrentUser().getId().toString();
        try {
            ShoppingListUser userToBeDeleted = userService.getUser(new ObjectId(userToBeDeletedId));
            registrationService.deleteInvitesOfUser(userToBeDeleted.getId());
            shoppingListService.deleteOrLeaveShoppingListsOfUser(userToBeDeleted);
            userService.deleteUser(userToBeDeleted.getId());
            LOGGER.info("User {} was succesfully deleted by {}", userToBeDeletedId, currentUser);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            LOGGER.info(
                    "User " + userToBeDeletedId + " could not be deleted by " + currentUser, e);
            return ResponseEntity.badRequest().build();
        }
    }
}
