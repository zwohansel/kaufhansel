package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
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


    @Test
    @Sql("/InsertTestList.sql")
    public void deleteShoppingListDeletesExistingList() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        List<ShoppingListInfoDto> lists = GetListsEndpointTest.getLists(client);

        client.delete()
                .uri(PATH, lists.get(0).getId())
                .exchange()
                .expectStatus()
                .is2xxSuccessful();

        assertThat(GetListsEndpointTest.getLists(client)).isEmpty();
    }

    @Test
    public void deleteShoppingListFailsIfListDoesNotExist() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        client.delete()
                .uri(PATH, 1234)
                .exchange()
                .expectStatus()
                .is4xxClientError();
    }
}
