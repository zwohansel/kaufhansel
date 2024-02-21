package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class DeleteListEndpointTest {
    private static final String PATH = "/api/shoppinglist/{id}";

    @Autowired
    private WebTestClient webClient;

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteShoppingListDeletesExistingList() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
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
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        client.delete()
                .uri(PATH, 1234)
                .exchange()
                .expectStatus()
                .is4xxClientError();
    }
}
