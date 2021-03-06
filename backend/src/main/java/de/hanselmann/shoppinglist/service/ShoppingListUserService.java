package de.hanselmann.shoppinglist.service;

import java.util.Optional;

import org.bson.types.ObjectId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.Nullable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListReference;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.utils.TimeSource;

@Service
public class ShoppingListUserService {
    private final ShoppingListUserRepository userRepository;
    private final CodeGenerator codeGenerator;
    private final PasswordEncoder passwordEncoder;
    private final EMailService emailService;
    private final TimeSource timeSource;

    @Autowired
    public ShoppingListUserService(ShoppingListUserRepository userRepository, CodeGenerator codeGenerator,
            PasswordEncoder passwordEncoder, EMailService emailService, TimeSource timeSource) {
        this.userRepository = userRepository;
        this.codeGenerator = codeGenerator;
        this.passwordEncoder = passwordEncoder;
        this.emailService = emailService;
        this.timeSource = timeSource;
    }

    public ShoppingListUser getCurrentUser() {
        return findCurrentUser().orElseThrow(() -> new IllegalArgumentException("User is not logged in."));
    }

    public ShoppingListUser getUser(ObjectId userId) {
        return findUser(userId).orElseThrow(() -> new IllegalArgumentException("User does not exist."));
    }

    public Optional<ShoppingListUser> findCurrentUser() {
        SecurityContext securityContext = SecurityContextHolder.getContext();
        Authentication auth = securityContext.getAuthentication();
        if (auth == null) {
            return Optional.empty();
        }
        return findUser(new ObjectId(auth.getName()));
    }

    public Optional<ShoppingListUser> findUser(ObjectId userId) {
        return userRepository.findById(userId);
    }

    public ShoppingListUser createNewUser(PendingRegistration pendingRegistration) {
        ShoppingListUser user = ShoppingListUser.create(pendingRegistration);
        synchronized (this) {
            if (userRepository.existsByEmailAddress(pendingRegistration.getEmailAddress())) {
                return null;
            }
            userRepository.save(user);
        }
        return user;
    }

    public void addShoppingListToUser(ShoppingListUser user, ObjectId shoppingListId,
            ShoppingListRole role) {
        ShoppingListReference shoppingListReference = new ShoppingListReference(shoppingListId, role);
        user.addShoppingList(shoppingListReference);
        userRepository.save(user);
    }

    public boolean removeShoppingListFromUser(ObjectId userId, ObjectId shoppingListId) {
        return userRepository.findById(userId).map(user -> removeShoppingListFromUser(user, shoppingListId))
                .orElse(false);
    }

    public boolean removeShoppingListFromUser(ShoppingListUser user, ObjectId shoppingListId) {
        user.deleteShoppingList(shoppingListId);
        userRepository.save(user);
        return true;
    }

    public Optional<ShoppingListUser> findByEmailAddress(String emailAddress) {
        if (emailAddress != null) {
            return userRepository.findUserByEmailAddress(emailAddress.toLowerCase());
        } else {
            return Optional.empty();
        }
    }

    public @Nullable ShoppingListRole getRoleForUser(ObjectId userId, ObjectId shoppingListId) {
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
    public @Nullable ShoppingListRole getRoleForUser(ShoppingListUser user, ObjectId shoppingListId) {
        return user.getShoppingLists().stream()
                .filter(refs -> refs.getShoppingListId().equals(shoppingListId))
                .findAny().map(ShoppingListReference::getRole)
                .orElse(null);
    }

    public void changePermission(ShoppingListUser userToBeChanged, ObjectId shopingListId,
            ShoppingListRole role) {
        ShoppingListReference referenceForUserToBeChanged = userToBeChanged.getShoppingLists().stream()
                .filter(ref -> ref.getShoppingListId().equals(shopingListId))
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
        user.setPasswordResetCode(resetCode, timeSource.dateTimeNow());
        userRepository.save(user);
        emailService.sendPasswortResetCodeMail(user, resetCode);
    }

    public boolean resetPassword(ShoppingListUser user, String resetCode, String password) {
        boolean isResetCodeValid = user.getPasswordResetCode()
                .map(code -> code.equals(resetCode.strip()))
                .orElse(false);
        boolean isResetCodeNotExpired = user.getPasswordResetRequestedAt()
                .map(at -> timeSource.dateTimeNow().isBefore(at.plusHours(1)))
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
        return userRepository.findExpiredPasswordResetRequests(olderThanMinutes).map(user -> {
            user.clearPasswordResetCode();
            userRepository.save(user);
            return user;
        }).count();
    }

    public boolean deleteUser(ObjectId userId) {
        userRepository.deleteById(userId);
        return true;
    }

}
