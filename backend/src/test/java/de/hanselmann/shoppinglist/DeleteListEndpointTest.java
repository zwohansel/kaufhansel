package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.service.AuthenticatedUserService;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@WebServerTestWithTestUser
public class DeleteListEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}";

    @Autowired
    private WebTestClient webClient;

    @Autowired
    private ShoppingListUserRepository userRepository;

    @MockBean
    private AuthenticatedUserService authenticatedUserService;

    @BeforeEach
    public void loginTestUser() {
        when(authenticatedUserService.findCurrentUser())
                .then(mock -> userRepository.findUserByEmailAddress("test@test.test"));
    }


    @Test
    @Sql("/InsertTestList.sql")
    public void deleteShoppingListDeletesExistingList() {
        List<ShoppingListInfoDto> lists = GetListsEndpointTest.getLists(webClient);

        webClient.delete()
                .uri(PATH, lists.get(0).getId())
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        assertThat(GetListsEndpointTest.getLists(webClient)).isEmpty();
    }
}
