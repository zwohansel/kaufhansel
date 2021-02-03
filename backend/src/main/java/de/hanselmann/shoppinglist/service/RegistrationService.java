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

    public boolean registerUser(String emailAddress, String userName, String password) {
        if (!isPasswordValid(password)) {
            return false;
        }

        PendingRegistration pendingRegistration;
        synchronized (this) {
            if (!isEmailAddressValid(emailAddress)) {
                return false;
            }
            pendingRegistration = PendingRegistration.create(emailAddress, userName,
                    passwordEncoder.encode(password), codeGenerator.generateRegistrationActivationCode());

            pendingRegistrationRepository.save(pendingRegistration);
        }

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
                .filter(PendingRegistration::isNotExpired).map(this::createUser).orElse(false);
    }

    private boolean createUser(PendingRegistration pendingRegistration) {
        ShoppingListUser user = ShoppingListUser.create(pendingRegistration);
        userService.save(user);
        pendingRegistrationRepository.delete(pendingRegistration);
        return true;
    }

    public String generateInviteCode() {
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.create(code, userService.getCurrentUser());
        inviteRepository.save(invite);
        return code;
    }

    public void sendInvite(String emailAddress) {
        // TODO: check: no Invite, PendigRegistration nor User with this email address
        // exists
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.createForEmailAddress(code, userService.getCurrentUser(), emailAddress);
        inviteRepository.save(invite);
        // TODO: send mail
    }

    public void sendInviteForShoppingList(String emailAddress, ObjectId shoppingListId) {
        // TODO: check: no Invite, PendigRegistration nor User with this email address
        // exists
        String code = codeGenerator.generateInviteCode();
        Invite invite = Invite.createForEmailAddressAndList(code, userService.getCurrentUser(), emailAddress,
                shoppingListId);
        inviteRepository.save(invite);
        // TODO: send mail
    }

}
