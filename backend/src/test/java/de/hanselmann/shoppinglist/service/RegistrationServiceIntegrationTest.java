package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.stream.Stream;

import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.model.ListInvite;
import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.repository.ListInviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;
import de.hanselmann.shoppinglist.service.RegistrationService.RegistrationProcessType;
import de.hanselmann.shoppinglist.testutils.Creator;

@SpringBootTest(classes = { RegistrationService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class RegistrationServiceIntegrationTest {

    @MockBean
    private ListInviteRepository inviteRepository;

    @MockBean
    private ShoppingListUserService userService;

    @MockBean
    private ShoppingListService shoppingListService;

    @MockBean
    private PendingRegistrationRepository pendingRegistrationRepository;

    @MockBean
    private PasswordEncoder passwordEncoder;

    @MockBean
    private CodeGenerator codeGenerator;

    @MockBean
    private EMailService emailService;

    @Autowired
    private RegistrationService cut;

    @ParameterizedTest
    @MethodSource("registrationTypeData")
    public void getTypeOfRegistrationProcess(String code, String inviteeEmailAddress,
            RegistrationProcessType expectedType) {
        ListInvite invite = Creator.invite(code, inviteeEmailAddress);
        when(inviteRepository.findByCode(eq("C0D4"))).thenReturn(Optional.of(invite));

        RegistrationProcessType actualType = cut.getTypeOfRegistrationProcess(code);

        assertThat(actualType).isEqualTo(expectedType);
    }

    private static Stream<Arguments> registrationTypeData() {
        return Stream.of(
                Arguments.of("C0D4", "new.hansel@mail.com", RegistrationProcessType.WITHOUT_EMAIL),
                Arguments.of("C0D4", null, RegistrationProcessType.FULL_REGISTRATION),
                Arguments.of("4RR0R", "new.hansel@mail.com", RegistrationProcessType.INVALID));
    }

    @Test
    public void registerUser() {
        ListInvite invite = Creator.invite("C0D4");
        when(inviteRepository.findByCode(eq("C0D4"))).thenReturn(Optional.of(invite));
        when(userService.isPasswordValid(any())).thenReturn(true);

        boolean success = cut.registerUser("C0D4", "new.hansel@mail.de", "Hansel", "Geheim!");
        assertThat(success).isTrue();

        verify(pendingRegistrationRepository).save(argThat(
                arg -> arg.getEmailAddress().equals("new.hansel@mail.de") && arg.getUserName().equals("Hansel")));
        verify(emailService).sendRegistrationActivationMail(argThat(
                arg -> arg.getEmailAddress().equals("new.hansel@mail.de") && arg.getUserName().equals("Hansel")));
        verify(userService, never()).createNewUser(any());
    }

    @Test
    public void registerUserWithEMailAddressFromInvite() {
        ListInvite invite = Creator.invite("C0D4", "new.hansel@mail.de");
        when(inviteRepository.findByCode(eq("C0D4"))).thenReturn(Optional.of(invite));
        when(userService.isPasswordValid(any())).thenReturn(true);
        when(userService.createNewUser(any())).thenReturn(Creator.emptyUser());

        boolean success = cut.registerUserWithEMailAddressFromInvite("C0D4", "Hansel", "Geheim!");
        assertThat(success).isTrue();

        verify(pendingRegistrationRepository, never()).save(any());
        verify(inviteRepository).delete(argThat(arg -> arg.getCode().equals("C0D4")));
        verify(userService).createNewUser(argThat(
                arg -> arg.getEmailAddress().equals("new.hansel@mail.de") && arg.getUserName().equals("Hansel")));
        verify(emailService).sendWelcomeEmail(any());
    }

    @Test
    public void activateValidPendingRegistration() {
        PendingRegistration registration = Creator.pendingRegistration(LocalDateTime.now());
        when(pendingRegistrationRepository.findByActivationCode(eq("ACT1V3"))).thenReturn(Optional.of(registration));
        when(userService.createNewUser(any())).thenReturn(Creator.emptyUser());

        boolean success = cut.activate("ACT1V3");
        assertThat(success).isTrue();

        verify(userService).createNewUser(argThat(
                arg -> arg.getEmailAddress().equals("test@test.de") && arg.getUserName().equals("Testuser")));
        verify(emailService).sendWelcomeEmail(any());
        verify(pendingRegistrationRepository).delete(argThat(arg -> arg.getActivationCode().equals("ACT1V3")));
    }

    @Test
    public void activationOfExpiredPendingRegistrationFails() {
        PendingRegistration registration = Creator
                .pendingRegistration(LocalDateTime.now().minusWeeks(PendingRegistration.EXPIRES_IN_WEEKS + 1));
        when(pendingRegistrationRepository.findByActivationCode(eq("ACT1V3"))).thenReturn(Optional.of(registration));
        when(userService.createNewUser(any())).thenReturn(Creator.emptyUser());

        boolean success = cut.activate("ACT1V3");
        assertThat(success).isFalse();
    }

    @Test
    public void generateInviteCode() {
        when(codeGenerator.generateInviteCode()).thenReturn("1NV1T3");
        ObjectId userId = new ObjectId();
        when(userService.getCurrentUser()).thenReturn(Creator.userWithOneListReference(userId));

        cut.generateInviteCode();
        verify(inviteRepository).save(
                argThat(arg -> arg.getCode().equals("1NV1T3") && arg.getGeneratedByUser().equals(userId)));
    }

    @ParameterizedTest
    @MethodSource("sendInviteData")
    public void sendInvite(boolean inviteExists, boolean pendingRegistrationExists, boolean userExists,
            boolean expectedSuccess) {
        when(codeGenerator.generateInviteCode()).thenReturn("1NV1T3");
        when(userService.getCurrentUser()).thenReturn(Creator.userWithOneListReference(new ObjectId()));

        when(inviteRepository.existsByInviteeEmailAddress(any())).thenReturn(inviteExists);
        when(pendingRegistrationRepository.existsByEmailAddress(any())).thenReturn(pendingRegistrationExists);
        when(userService.existsUserWithEmailAddress(any())).thenReturn(userExists);

        boolean success = cut.sendListInvite("neuer.hansel@mail.de");
        assertThat(success).isEqualTo(expectedSuccess);
        if (success) {
            verify(emailService).sendInviteMail(eq("neuer.hansel@mail.de"), eq("1NV1T3"), eq("Testuser"));
        }
    }

    private static Stream<Arguments> sendInviteData() {
        return Stream.of(Arguments.of(false, false, false, true),
                Arguments.of(true, false, false, false),
                Arguments.of(false, true, false, false),
                Arguments.of(false, false, true, false));
    }

    @Test
    public void sendInviteForShoppingList() {
        when(codeGenerator.generateInviteCode()).thenReturn("1NV1T3");
        when(userService.getCurrentUser()).thenReturn(Creator.userWithOneListReference(new ObjectId()));

        ObjectId shoppingListId = new ObjectId();
        boolean success = cut.sendInviteForShoppingList("neuer.hansel@mail.de", shoppingListId);
        assertThat(success).isTrue();
        verify(emailService).sendInviteMail(eq("neuer.hansel@mail.de"), eq("1NV1T3"), eq("Testuser"));
    }

}
