package de.hanselmann.shoppinglist.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;
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

    @Autowired
    public RegistrationService(InviteRepository inviteRepository, ShoppingListUserRepository userRepository,
            PendingRegistrationRepository pendingRegistrationRepository,
            PasswordEncoder passwordEncoder, CodeGenerator codeGenerator) {
        this.inviteRepository = inviteRepository;
        this.userRepository = userRepository;
        this.pendingRegistrationRepository = pendingRegistrationRepository;
        this.passwordEncoder = passwordEncoder;
        this.codeGenerator = codeGenerator;
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

        synchronized (this) {
            if (!isEmailAddressValid(emailAddress)) {
                return false;
            }
            PendingRegistration pendingRegistration = PendingRegistration.create(emailAddress, userName,
                    passwordEncoder.encode(password), codeGenerator.generateRegistrationActivationCode());

            pendingRegistrationRepository.save(pendingRegistration);
            return true;
        }
    }

}
