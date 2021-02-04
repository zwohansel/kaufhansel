package de.hanselmann.shoppinglist.service;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.Invite;
import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.InviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;

@Service
public class RegistrationService {
    private final InviteRepository inviteRepository;
    private final ShoppingListUserService userService;
    private final ShoppingListService shoppingListService;
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final PasswordEncoder passwordEncoder;
    private final CodeGenerator codeGenerator;
    private final EMailService emailService;

    @Autowired
    public RegistrationService(InviteRepository inviteRepository, ShoppingListUserService userService,
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

    public boolean isInviteCodeValid(String inviteCode) {
        return inviteRepository.findByCode(inviteCode).isPresent();
    }

    public boolean isEmailAddressValid(String emailAddress) {
        return !userService.existsUserWithEmailAddress(emailAddress)
                && !pendingRegistrationRepository.existsByEmailAddress(emailAddress);
    }

    public boolean isPasswordValid(String password) {
        return password != null && password.strip().length() >= 8;
    }

    public boolean registerUser(String inviteCode, String emailAddress, String userName, String password) {
        return inviteRepository.findByCode(inviteCode)
                .map(invite -> invite.forEmailAddress(emailAddress))
                .map(invite -> registerUser(invite, userName, password, true))
                .orElse(false);
    }

    public boolean registerUserWithEMailAddressFromInvite(String inviteCode, String userName, String password) {
        return inviteRepository.findByCode(inviteCode)
                .map(invite -> {
                    if (registerUser(invite, userName, password, false)) {
                        inviteRepository.delete(invite);
                        return true;
                    }
                    return false;

                })
                .orElse(false);
    }

    private boolean registerUser(Invite invite, String userName, String password, boolean requireActivation) {
        if (invite.getInviteeEmailAddress() == null) {
            return false;
        }

        if (!isPasswordValid(password)) {
            return false;
        }

        final PendingRegistration pendingRegistration = PendingRegistration.create(
                invite,
                userName,
                passwordEncoder.encode(password),
                codeGenerator.generateRegistrationActivationCode());

        if (requireActivation) {
            synchronized (this) {
                if (!isEmailAddressValid(pendingRegistration.getEmailAddress())) {
                    return false;
                }
                pendingRegistrationRepository.save(pendingRegistration);
            }

            try {
                emailService.sendRegistrationActivationMail(pendingRegistration);
            } catch (Exception e) {
                pendingRegistrationRepository.delete(pendingRegistration);
                throw e;
            }
        } else {
            return createUser(pendingRegistration);
        }

        return true;
    }

    public boolean activate(String activationCode) {
        return pendingRegistrationRepository.findByActivationCode(activationCode)
                .filter(PendingRegistration::isNotExpired)
                .map(this::createUser)
                .orElse(false);
    }

    private boolean createUser(PendingRegistration pendingRegistration) {
        ShoppingListUser user = userService.createNewUser(pendingRegistration);
        if (user == null) {
            return false;
        }
        try {
            pendingRegistration.getInvitedToShoppingLists()
                    .forEach(list -> shoppingListService.addUserToShoppingList(list, user));
        } finally {
            pendingRegistrationRepository.delete(pendingRegistration);
            emailService.sendWelcomeEmail(user);
        }
        return true;
    }

    public String generateInviteCode() {
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.create(code, userService.getCurrentUser());
        inviteRepository.save(invite);
        return code;
    }

    public boolean sendInvite(String emailAddress) {
        if (isEmailAddressAlreadyInUse(emailAddress)) {
            return false;
        }
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.createForEmailAddress(code, userService.getCurrentUser(), emailAddress);
        inviteRepository.save(invite);

        try {
            emailService.sendInviteMail(emailAddress, code, userService.getCurrentUser().getUsername());
        } catch (Exception e) {
            inviteRepository.delete(invite);
            return false;
        }
        return true;
    }

    private boolean isEmailAddressAlreadyInUse(String emailAddress) {
        return inviteRepository.existsByInviteeEmailAddress(emailAddress) ||
                pendingRegistrationRepository.existsByEmailAddress(emailAddress) ||
                userService.existsUserWithEmailAddress(emailAddress);
    }

    public boolean sendInviteForShoppingList(String emailAddress, ObjectId shoppingListId) {
        if (isEmailAddressAlreadyInUse(emailAddress)) {
            return false;
        }
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.createForEmailAddressAndList(
                code,
                userService.getCurrentUser(),
                emailAddress,
                shoppingListId);
        inviteRepository.save(invite);

        try {
            emailService.sendInviteMail(emailAddress, code, userService.getCurrentUser().getUsername());
        } catch (Exception e) {
            inviteRepository.delete(invite);
            throw e;
        }
        return true;
    }

}
