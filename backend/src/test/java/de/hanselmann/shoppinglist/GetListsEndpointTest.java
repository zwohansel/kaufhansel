package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class GetListsEndpointTest {
    private static final String PATH = "/api/shoppinglists";

    @Autowired
    private WebTestClient webClient;

    public static List<ShoppingListInfoDto> getLists(WebTestClient webClient) {
        return requestLists(webClient).returnResult().getResponseBody();
    }

    private static WebTestClient.ListBodySpec<ShoppingListInfoDto> requestLists(WebTestClient webClient) {
        return webClient.get()
                .uri(PATH)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class);
    }

    public static ShoppingListInfoDto getSingleList(WebTestClient webClient) {
        return requestLists(webClient).hasSize(1).returnResult().getResponseBody().get(0);
    }

    @Test
    public void shoppingListEndpointFailsIfUserNotAuthenticated() {
        webClient.get()
                .uri(PATH)
                .exchange()
                .expectStatus()
                .is4xxClientError();
    }

    @Test
    public void shoppingListEndpointReturnsEmptyListIfUserHasNoLists() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        client.get()
                .uri(PATH)
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBodyList(ShoppingListInfoDto.class)
                .hasSize(0);
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void shoppingListEndpointReturnsExistingList() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        List<ShoppingListInfoDto> lists = getLists(client);

        assertThat(lists).as("Response body contains single list info object").singleElement();
        ShoppingListInfoDto listInfo = lists.get(0);
        assertThat(listInfo.getName()).isEqualTo("Alice List");
        assertThat(listInfo.getOtherUsers()).as("No other user can access the created list").isEmpty();

        ShoppingListPermissionsDto permissions = listInfo.getPermissions();
        assertThat(permissions).as("List info has user permissions").isNotNull();
        assertThat(permissions.getRole()).as("User has admin role").isEqualTo(ShoppingListRole.ADMIN);
        assertThat(permissions.isCanCheckItems()).as("User has the permission to check items").isTrue();
        assertThat(permissions.isCanEditItems()).as("User has the permission to edit items").isTrue();
        assertThat(permissions.isCanEditList()).as("User has the permission to edit the list").isTrue();
    }

}
