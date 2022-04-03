package de.hanselmann.shoppinglist;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import static org.assertj.core.api.Assertions.assertThat;

@WebServerTestWithTestUser
public class ClearShoppingListEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/clear";

    @Autowired
    private WebTestClient webClient;

    public static WebTestClient.ResponseSpec clearList(WebTestClient webClient, ShoppingListInfoDto list) {
        return webClient.post()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .exchange();
    }

    @Test
    @Sql("/InsertTestList.sql")
    @Sql("/InsertTestItem.sql")
    public void clearNonEmptyList() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isNotEmpty();
        clearList(client, list).expectStatus().is2xxSuccessful();
        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isEmpty();
    }

    @Test
    @Sql("/InsertTestList.sql")
    public void clearEmptyList() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        clearList(client, list).expectStatus().is2xxSuccessful();
        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isEmpty();
    }

    @Test
    @Sql("/InsertOtherUser.sql")
    @Sql("/InsertListOfOtherSharedWithTestUserAsReadOnly.sql")
    @Sql("/InsertTestItemInOtherList.sql")
    public void clearListFailsIfPermissionIsReadOnly() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isNotEmpty();
        clearList(client, list).expectStatus().is4xxClientError();
        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isNotEmpty();
    }

}
