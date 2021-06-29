package de.hanselmann.shoppinglist.controller;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase.Replace;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.transaction.annotation.Transactional;

import de.hanselmann.shoppinglist.service.AuthenticatedUserService;

@SpringBootTest(webEnvironment = WebEnvironment.NONE)
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
@AutoConfigureTestDatabase(replace = Replace.NONE)
@ActiveProfiles("test")
public class ShoppingListControllerTest {

    @Autowired
    private ShoppingListController cut;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    @Test
    public void test() {
        when(authenticatedUserService.findCurrentUser()).thenReturn(Optional.empty());
        assertThrows(IllegalArgumentException.class, () -> cut.getShoppingLists());
    }

}
