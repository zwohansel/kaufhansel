package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.restapi.dto.NewShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class CreateListEndpointTest {
    private static final String PATH = "/api/shoppinglist";

    @Autowired
    private WebTestClient webClient;

    public static ShoppingListInfoDto createList(WebTestClient client, String name) {
        return requestCreateList(client, name)
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListInfoDto.class)
                .returnResult().getResponseBody();
    }

    public static WebTestClient.ResponseSpec requestCreateList(WebTestClient client, String name) {
        NewShoppingListDto newListDto = new NewShoppingListDto();
        newListDto.setName(name);
        return client.post()
                .uri(PATH)
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(newListDto)
                .exchange();
    }

    @Test
    public void createsNewList() {
        WebTestClient client = LoginTest.loggedInClient(webClient);

        final String newListName = "New Shopping List";
        ShoppingListInfoDto createdList = createList(client, newListName);

        assertThat(createdList.getName()).isEqualTo(newListName);
        assertThat(createdList.getOtherUsers()).as("No other user can access the created list").isEmpty();

        ShoppingListPermissionsDto permissions = createdList.getPermissions();
        assertThat(permissions).as("Creation response has permissions").isNotNull();
        assertThat(permissions.getRole()).as("Creator has admin role").isEqualTo(ShoppingListRole.ADMIN);
        assertThat(permissions.isCanCheckItems()).as("Creator has the permission to check items").isTrue();
        assertThat(permissions.isCanEditItems()).as("Creator has the permission to edit items").isTrue();
        assertThat(permissions.isCanEditList()).as("Creator has the permission to edit the list").isTrue();

        List<ShoppingListInfoDto> lists = GetListsEndpointTest.getLists(client);

        assertThat(lists).as("/shoppinglist returns created list").singleElement();
        assertThat(lists.get(0).getId()).as("id of list returned by /shoppinglist matches id of created list")
                .isEqualTo(createdList.getId());
    }

    @Test
    public void returnsBadRequestIfNoNameIsGiven() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        requestCreateList(client, null).expectStatus().isBadRequest();

        // Check that no list has been created
        assertThat(GetListsEndpointTest.getLists(client)).isEmpty();
    }

    @Test
    public void returnsBadRequestIfEmptyNameIsGiven() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        requestCreateList(client, "").expectStatus().isBadRequest();

        // Check that no list has been created
        assertThat(GetListsEndpointTest.getLists(client)).isEmpty();
    }

    @Test
    public void returnsBadRequestIfBlankNameIsGiven() {
        WebTestClient client = LoginTest.loggedInClient(webClient);
        requestCreateList(client, " \t\n ").expectStatus().isBadRequest();

        // Check that no list has been created
        assertThat(GetListsEndpointTest.getLists(client)).isEmpty();
    }
}
