package de.hanselmann.shoppinglist.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.ListInvite;
import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingList;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ListInviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;

@Service
public class RegistrationService {
    private final ListInviteRepository inviteRepository;
    private final ShoppingListUserService userService;
    private final ShoppingListService shoppingListService;
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final PasswordEncoder passwordEncoder;
    private final CodeGenerator codeGenerator;
    private final EMailService emailService;

    @Autowired
    public RegistrationService(ListInviteRepository inviteRepository, ShoppingListUserService userService,
            ShoppingListService shoppingListService,
            PendingRegistrationRepository pendingRegistrationRepository,
            PasswordEncoder passwordEncoder, CodeGenerator codeGenerator, EMailService emailService) {
        this.inviteRepository = inviteRepository;
        this.userService = userService;
        this.shoppingListService = shoppingListService;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.passwordEncoder = passwordEncoder;
        this.codeGenerator = codeGenerator;
        this.emailService = emailService;
    }

    public boolean isEmailAddressUnused(String emailAddress) {
        return !userService.existsUserWithEmailAddress(emailAddress)
                && !pendingRegistrationRepository.existsByEmailAddress(emailAddress);
    }

    public boolean isPasswordValid(String password) {
        return userService.isPasswordValid(password);
    }

    public boolean registerUser(String emailAddress, String userName, String password) {
        if (!isPasswordValid(password)) {
            return false;
        }

        final PendingRegistration pendingRegistration = PendingRegistration.create(
                emailAddress.trim().toLowerCase(),
                userName,
                passwordEncoder.encode(password),
                codeGenerator.generateRegistrationActivationCode());

        if (!isEmailAddressUnused(pendingRegistration.getEmailAddress())) {
            return false;
        }
        pendingRegistrationRepository.save(pendingRegistration);

        try {
            emailService.sendRegistrationActivationMail(pendingRegistration);
        } catch (Exception e) {
            pendingRegistrationRepository.delete(pendingRegistration);
            throw e;
        }

        return true;
    }

    public boolean activate(String activationCode) {
        return pendingRegistrationRepository.findByActivationCode(activationCode)
                .filter(PendingRegistration::isNotExpired)
                .map(pendingRegistration -> {
                    try {
                        return createUser(pendingRegistration);
                    } finally {
                        pendingRegistrationRepository.delete(pendingRegistration);
                    }
                })
                .orElse(false);
    }

    private boolean createUser(PendingRegistration pendingRegistration) {
        ShoppingListUser user = userService.createNewUser(pendingRegistration);
        if (user == null) {
            return false;
        }

        List<ListInvite> invites = inviteRepository.findByInviteeEmailAddress(user.getEmailAddress());
        invites.forEach(invite -> shoppingListService.addUserToShoppingList(invite.getShoppingList(), user));
        inviteRepository.deleteAll(invites);

        emailService.sendWelcomeEmail(user);
        return true;
    }

    private boolean isEmailAddressAlreadyInUse(String emailAddress) {
        return inviteRepository.existsByInviteeEmailAddress(emailAddress) ||
                pendingRegistrationRepository.existsByEmailAddress(emailAddress) ||
                userService.existsUserWithEmailAddress(emailAddress);
    }

    public boolean sendInviteForShoppingList(String emailAddress, long shoppingListId) {
        if (isEmailAddressAlreadyInUse(emailAddress)) {
            return false;
        }
        return userService.getCurrentUser().getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == shoppingListId
                        && permission.getRole().canEditList())
                .findAny().map(permission -> createListInvite(emailAddress, permission.getList())).orElse(false);
    }

    private boolean createListInvite(String emailAddress, ShoppingList list) {
        boolean alreadyInvited = inviteRepository.existsByInviteeEmailAddress(emailAddress);

        ListInvite invite = ListInvite.createForEmailAddressAndList(
                userService.getCurrentUser(),
                emailAddress,
                list);
        inviteRepository.save(invite);

        if (!alreadyInvited) {
            sendInviteEmail(emailAddress, invite);
        }
        return true;
    }

    private void sendInviteEmail(String emailAddress, ListInvite invite) {
        try {
            emailService.sendInviteMail(emailAddress, userService.getCurrentUser().getUsername());
        } catch (Exception e) {
            inviteRepository.delete(invite);
            throw e;
        }
    }
}
