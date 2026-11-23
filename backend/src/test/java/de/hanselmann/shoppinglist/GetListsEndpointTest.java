package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.client.RestTestClient;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class GetListsEndpointTest {
    private static final String PATH = "/api/shoppinglists";
    private static final ParameterizedTypeReference<List<ShoppingListInfoDto>> LIST_INFO_LIST = new ParameterizedTypeReference<>() {
    };

    @Autowired
    private RestTestClient webClient;

    public static List<ShoppingListInfoDto> getLists(RestTestClient webClient) {
        return requestLists(webClient).returnResult().getResponseBody();
    }

    private static RestTestClient.BodySpec<List<ShoppingListInfoDto>, ?> requestLists(RestTestClient webClient) {
        return webClient.get()
                .uri(PATH)
                .exchange()
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(LIST_INFO_LIST);
    }

    public static ShoppingListInfoDto getSingleList(RestTestClient webClient) {
        return requestLists(webClient).value(lists -> assertThat(lists).hasSize(1))
                .returnResult()
                .getResponseBody()
                .get(0);
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
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        client.get()
                .uri(PATH)
                .exchange().expectStatus()
                .is2xxSuccessful()
                .expectBody(LIST_INFO_LIST)
                .value(lists -> assertThat(lists).isEmpty());
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void shoppingListEndpointReturnsExistingList() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
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
