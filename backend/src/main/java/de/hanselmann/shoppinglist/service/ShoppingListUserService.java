package de.hanselmann.shoppinglist.service;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListPermission;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.security.AuthenticatedToken;

@Service
public class ShoppingListUserService {
    private final ShoppingListUserRepository userRepository;
    private final CodeGenerator codeGenerator;
    private final PasswordEncoder passwordEncoder;
    private final EMailService emailService;
    private final TimeService timeService;

    @Autowired
    public ShoppingListUserService(ShoppingListUserRepository userRepository, CodeGenerator codeGenerator,
            PasswordEncoder passwordEncoder, EMailService emailService, TimeService timeService) {
        this.userRepository = userRepository;
        this.codeGenerator = codeGenerator;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.timeService = timeService;
    }

    public ShoppingListUser getCurrentUser() {
        return findCurrentUser().orElseThrow(() -> new IllegalArgumentException("User is not logged in."));
    }

    public Optional<ShoppingListUser> findCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        if (auth != null && auth.isAuthenticated()) {
            Long userId = ((AuthenticatedToken) auth).getUserId();
            return findUser(userId);
        }
        return Optional.empty();
    }

    public ShoppingListUser getUser(long userId) {
        return findUser(userId).orElseThrow(() -> new IllegalArgumentException("User does not exist."));
    }

    public Optional<ShoppingListUser> findUser(long userId) {
        return userRepository.findById(userId);
    }

    public ShoppingListUser createNewUser(PendingRegistration pendingRegistration) {
        ShoppingListUser user = ShoppingListUser.create(pendingRegistration, timeService.now());
        synchronized (this) {
            if (userRepository.existsByEmailAddress(pendingRegistration.getEmailAddress())) {
                return null;
            }
            userRepository.save(user);
        }
        return user;
    }

    public Optional<ShoppingListUser> findByEmailAddress(String emailAddress) {
        if (emailAddress != null) {
            return userRepository.findUserByEmailAddress(emailAddress.toLowerCase());
        } else {
            return Optional.empty();
        }
    }

    public @Nullable ShoppingListRole getRoleForUser(long userId, long shoppingListId) {
        return userRepository.findById(userId).map(user -> getRoleForUser(user, shoppingListId)).orElse(null);
    }

    /**
     * Role of the user in the shopping list with the given id.
     *
     * @param user           a shopping list user
     * @param shoppingListId the id of a shopping list
     * @return the role of the user in the shopping list or {@code null} if the user
     *         does not know the list.
     */
    public @Nullable ShoppingListRole getRoleForUser(ShoppingListUser user, long shoppingListId) {
        return user.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == shoppingListId)
                .findAny().map(ShoppingListPermission::getRole)
                .orElse(null);
    }

    public void changePermission(ShoppingListUser userToBeChanged, long shoppingListId,
            ShoppingListRole role) {
        ShoppingListPermission referenceForUserToBeChanged = userToBeChanged.getShoppingListPermissions().stream()
                .filter(permission -> permission.getList().getId() == shoppingListId)
                .findAny()
                .orElseThrow();
        referenceForUserToBeChanged.setRole(role);
        userRepository.save(userToBeChanged);
    }

    public boolean existsUserWithEmailAddress(String emailAddress) {
        return userRepository.existsByEmailAddress(emailAddress);
    }

    public void requestPasswordReset(ShoppingListUser user) {
        String resetCode = codeGenerator.generatePasswordResetCode();
        user.setPasswordResetCode(resetCode, timeService.now());
        userRepository.save(user);
        emailService.sendPasswortResetCodeMail(user, resetCode);
    }

    public boolean resetPassword(ShoppingListUser user, String resetCode, String password) {
        LocalDateTime now = timeService.now();
        boolean isResetCodeValid = user.getPasswordResetCode()
                .map(code -> code.equals(resetCode.strip()))
                .orElse(false);
        boolean isResetCodeNotExpired = user.getPasswordResetRequestedAt()
                .map(at -> now.isBefore(at.plusHours(1)))
                .orElse(false);
        if (isResetCodeValid && isResetCodeNotExpired && isPasswordValid(password)) {
            user.setPassword(passwordEncoder.encode(password));
            user.clearPasswordResetCode();
            userRepository.save(user);
            emailService.sendPasswortSuccessfullyChangedMail(user);
            return true;
        }
        return false;
    }

    public boolean isPasswordValid(String password) {
        return password != null && password.strip().length() >= 8;
    }

    public long resetPendingPasswordResetRequestsOlderThanMinutes(long olderThanMinutes) {
        return userRepository.findExpiredPasswordResetRequests(olderThanMinutes).stream().map(user -> {
            user.clearPasswordResetCode();
            userRepository.save(user);
            return user;
        }).count();
    }

    public boolean deleteUser(ShoppingListUser user) {
        userRepository.delete(user);
        return true;
    }

}
