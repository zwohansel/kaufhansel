package de.hanselmann.shoppinglist.service;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.TestPropertySource;

import de.hanselmann.shoppinglist.repository.InviteRepository;
import de.hanselmann.shoppinglist.repository.PendingRegistrationRepository;

@SpringBootTest(classes = { RegistrationService.class })
@TestPropertySource(locations = "classpath:application-test.properties")
public class RegistrationServiceIntegrationTest {

    @MockBean
    private InviteRepository inviteRepository;

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

    @Test
    public void test() {
        assertThat(cut).isNotNull();
    }

}
