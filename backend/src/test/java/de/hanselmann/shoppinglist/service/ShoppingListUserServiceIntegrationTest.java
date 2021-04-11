package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.time.LocalDateTime;

import org.bson.types.ObjectId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.model.PendingRegistration;
import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.model.ShoppingListUser;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.testutils.Creator;

@SpringBootTest(classes = { ShoppingListUserService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class ShoppingListUserServiceIntegrationTest {

    @MockBean
    private ShoppingListUserRepository userRepository;

    @MockBean
    private CodeGenerator codeGenerator;

    @MockBean
    private PasswordEncoder passwordEncoder;

    @MockBean
    private EMailService emailService;

    @Autowired
    private ShoppingListUserService cut;

    @Test
    public void createNewUserFromPendingRegistration() {
        when(userRepository.existsByEmailAddress("test@test.de")).thenReturn(false);

        ShoppingListUser user = cut.createNewUser(Creator.pendingRegistration());
        assertThat(user).isNotNull();
    }

    @Test
    public void createNewUserFromPendingRegistrationFailsIfExpired() {
        LocalDateTime creationDate = LocalDateTime.now().minusWeeks(PendingRegistration.EXPIRES_IN_WEEKS + 1);

        assertThrows(IllegalArgumentException.class,
                () -> cut.createNewUser(Creator.pendingRegistration(creationDate)));
    }

    @Test
    public void createNewUserFromPendingRegistrationFailsIfEmailAlreadyPresent() {
        when(userRepository.existsByEmailAddress("test@test.de")).thenReturn(true);

        ShoppingListUser user = cut.createNewUser(Creator.pendingRegistration());
        assertThat(user).isNull();
    }

    @Test
    public void addShoppingListToUser() {
        ShoppingListUser user = Creator.userWithTwoLists(new ObjectId(), new ObjectId());

        cut.addShoppingListToUser(user, new ObjectId(), ShoppingListRole.CHECK_ONLY);

        assertThat(user.getShoppingLists().size()).isEqualTo(3);
    }

}
