package de.hanselmann.shoppinglist.service;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest(classes = { ShoppingListUserService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class ShoppingListUserServiceIntegrationTest {

//    @MockBean
//    private ShoppingListUserRepository userRepository;
//
//    @MockBean
//    private CodeGenerator codeGenerator;
//
//    @MockBean
//    private PasswordEncoder passwordEncoder;
//
//    @MockBean
//    private EMailService emailService;
//
//    @MockBean
//    private TimeSource timeSource;
//
//    @Autowired
//    private ShoppingListUserService cut;
//
//    @Test
//    public void createNewUserFromPendingRegistration() {
//        when(userRepository.existsByEmailAddress("test@test.de")).thenReturn(false);
//
//        ShoppingListUser user = cut.createNewUser(Creator.pendingRegistration());
//        assertThat(user).isNotNull();
//    }
//
//    @Test
//    public void createNewUserFromPendingRegistrationFailsIfExpired() {
//        LocalDateTime creationDate = LocalDateTime.now().minusWeeks(PendingRegistration.EXPIRES_IN_WEEKS + 1);
//
//        assertThrows(IllegalArgumentException.class,
//                () -> cut.createNewUser(Creator.pendingRegistration(creationDate)));
//    }
//
//    @Test
//    public void createNewUserFromPendingRegistrationFailsIfEmailAlreadyPresent() {
//        when(userRepository.existsByEmailAddress("test@test.de")).thenReturn(true);
//
//        ShoppingListUser user = cut.createNewUser(Creator.pendingRegistration());
//        assertThat(user).isNull();
//    }
//
//    @Test
//    public void addShoppingListToUser() {
//        ShoppingListUser user = Creator.userWithTwoListReferences(new ObjectId(), new ObjectId());
//
//        cut.addShoppingListToUser(user, new ObjectId(), ShoppingListRole.CHECK_ONLY);
//
//        assertThat(user.getShoppingListPermissions().size()).isEqualTo(3);
//    }
//
//    @Test
//    public void removeShoppingListFromUser() {
//        ObjectId userId = new ObjectId();
//        ObjectId shoppingListId = new ObjectId();
//        ShoppingListUser user = Creator.userWithTwoListReferences(userId, shoppingListId);
//        when(userRepository.findById(eq(userId))).thenReturn(Optional.of(user));
//
//        assertThat(user.getShoppingListPermissions().size()).isEqualTo(2);
//        cut.removeShoppingListFromUser(userId, shoppingListId);
//        assertThat(user.getShoppingListPermissions().size()).isEqualTo(1);
//    }
//
//    @Test
//    public void getRoleForUser() {
//        ObjectId userId = new ObjectId();
//        ObjectId shoppingListId = new ObjectId();
//        ShoppingListUser user = Creator.userWithCheckOnlyListReferenceAnd(userId, shoppingListId,
//                ShoppingListRole.ADMIN);
//        when(userRepository.findById(eq(userId))).thenReturn(Optional.of(user));
//
//        ShoppingListRole role = cut.getRoleForUser(userId, shoppingListId);
//        assertThat(role).isEqualTo(ShoppingListRole.ADMIN);
//    }
//
//    @Test
//    public void changePermission() {
//        ObjectId shoppingListId = new ObjectId();
//        ShoppingListUser user = Creator.userWithCheckOnlyListReferenceAnd(new ObjectId(), shoppingListId,
//                ShoppingListRole.ADMIN);
//
//        cut.changePermission(user, shoppingListId, ShoppingListRole.READ_ONLY);
//
//        assertThat(user.getShoppingListPermissions().stream().map(l -> l.getRole()))
//                .containsExactlyInAnyOrder(ShoppingListRole.READ_ONLY, ShoppingListRole.CHECK_ONLY);
//    }
//
//    @Test
//    public void successfullyResetPassword() {
//        when(timeSource.dateTimeNow()).thenReturn(LocalDateTime.now());
//
//        String passwordResetCode = "P4SSW0RD";
//        ShoppingListUser user = requestAndTestPasswordReset(passwordResetCode);
//
//        boolean success = cut.resetPassword(user, passwordResetCode, "N3u3$P4$Sw0rT!");
//        assertThat(success).isTrue();
//        assertThat(user.getPasswordResetCode().isEmpty()).isTrue();
//        assertThat(user.getPasswordResetRequestedAt().isEmpty()).isTrue();
//        org.mockito.Mockito.verify(emailService).sendPasswortSuccessfullyChangedMail(any());
//    }
//
//    @Test
//    public void resetPasswordFailsWithInvalidCode() {
//        when(timeSource.dateTimeNow()).thenReturn(LocalDateTime.now());
//
//        String passwordResetCode = "P4SSW0RD";
//        ShoppingListUser user = requestAndTestPasswordReset(passwordResetCode);
//
//        boolean success = cut.resetPassword(user, "WR0NG", "N3u3$P4$Sw0rT!");
//        assertThat(success).isFalse();
//        assertThat(user.getPasswordResetCode().isPresent()).isTrue();
//        assertThat(user.getPasswordResetRequestedAt().isPresent()).isTrue();
//    }
//
//    @Test
//    public void resetPasswordFailsWithExpiredCode() {
//        when(timeSource.dateTimeNow()).thenReturn(LocalDateTime.of(2021, 1, 1, 12, 0));
//
//        String passwordResetCode = "P4SSW0RD";
//        ShoppingListUser user = requestAndTestPasswordReset(passwordResetCode);
//
//        when(timeSource.dateTimeNow()).thenReturn(LocalDateTime.of(2021, 1, 1, 15, 0));
//
//        boolean success = cut.resetPassword(user, passwordResetCode, "N3u3$P4$Sw0rT!");
//        assertThat(success).isFalse();
//        assertThat(user.getPasswordResetCode().isPresent()).isTrue();
//        assertThat(user.getPasswordResetRequestedAt().isPresent()).isTrue();
//    }
//
//    private ShoppingListUser requestAndTestPasswordReset(String passwordResetCode) {
//        when(codeGenerator.generatePasswordResetCode()).thenReturn(passwordResetCode);
//
//        ObjectId userId = new ObjectId();
//        ObjectId shoppingListId = new ObjectId();
//        ShoppingListUser user = Creator.userWithTwoListReferences(userId, shoppingListId);
//
//        cut.requestPasswordReset(user);
//
//        assertThat(user.getPasswordResetCode().get()).isEqualTo(passwordResetCode);
//        assertThat(user.getPasswordResetRequestedAt().isPresent()).isTrue();
//        return user;
//    }
//
//    @Test
//    public void deleteUser() {
//        ObjectId userId = new ObjectId();
//        cut.deleteUser(userId);
//        org.mockito.Mockito.verify(userRepository).deleteById(eq(userId));
//    }

}
