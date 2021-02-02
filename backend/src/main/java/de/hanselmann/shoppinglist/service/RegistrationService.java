package de.hanselmann.shoppinglist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.InviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;

@Service
public class RegistrationService {
    private final InviteRepository inviteRepository;
    private final ShoppingListUserRepository userRepository;
    private final PendingRegistrationRepository pendingRegistrationRepository;
    private final PasswordEncoder passwordEncoder;
    private final CodeGenerator codeGenerator;
    private final EMailService emailService;

    @Autowired
    public RegistrationService(InviteRepository inviteRepository, ShoppingListUserRepository userRepository,
            PendingRegistrationRepository pendingRegistrationRepository,
            PasswordEncoder passwordEncoder, CodeGenerator codeGenerator, EMailService emailService) {
        this.inviteRepository = inviteRepository;
        this.userRepository = userRepository;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.passwordEncoder = passwordEncoder;
        this.codeGenerator = codeGenerator;
        this.emailService = emailService;
    }

    public boolean isInviteCodeValid(String inviteCode) {
        return inviteRepository.findByCode(inviteCode).isPresent();
    }

    public boolean isEmailAddressValid(String emailAddress) {
        return !userRepository.existsByEmailAddress(emailAddress)
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
        userRepository.save(user);
        pendingRegistrationRepository.delete(pendingRegistration);
        return true;
    }

}
