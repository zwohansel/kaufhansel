package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.restapi.dto.AddUserToShoppingListDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListUserReferenceDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class AddUserToListTest {
    private static final String PATH = "/api/shoppinglist/{id}/user";

    @Autowired
    private WebTestClient webClient;

    public static ShoppingListUserReferenceDto addUserToList(WebTestClient webClient, ShoppingListInfoDto list,
            String userEmail) {
        return requestAddUserToList(webClient, list, userEmail)
                .expectStatus()
                .is2xxSuccessful()
                .expectBody(ShoppingListUserReferenceDto.class)
                .returnResult()
                .getResponseBody();
    }

    private static ResponseSpec requestAddUserToList(WebTestClient webClient, ShoppingListInfoDto list,
            String userEmail) {
        AddUserToShoppingListDto addUserDto = new AddUserToShoppingListDto();
        addUserDto.setEmailAddress(userEmail);
        return webClient.put()
                .uri(PATH, list.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValue(addUserDto)
                .exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertBob.sql")
    public void addingBobToAliceListsGrantsBobReadWritePermissions() {
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(aliceClient);

        // Add other user to the list
        ShoppingListUserReferenceDto addedUser = addUserToList(aliceClient, list, LoginTest.BOB_EMAIL);
        assertThat(addedUser.getUserEmailAddress()).isEqualTo(LoginTest.BOB_EMAIL);
        assertThat(addedUser.getUserName()).isNotEmpty();
        assertThat(addedUser.getUserRole()).isEqualTo(ShoppingListRole.READ_WRITE);
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    @Sql("/InsertBob.sql")
    public void bobCanReadAliceListAfterHeWasAdded() {
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        WebTestClient bobsClient = LoginTest.loginAsBob(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(aliceClient);

        // Other user has no access to the list before he is added
        assertThat(GetListsEndpointTest.getLists(bobsClient)).isEmpty();
        GetListItemsEndpointTest.requestListItems(bobsClient, list).expectStatus().is4xxClientError();

        // Add other user to the list
        addUserToList(aliceClient, list, LoginTest.BOB_EMAIL);

        // Other user can now access the list
        assertThat(GetListsEndpointTest.getLists(bobsClient)).hasSize(1);
        assertThat(GetListsEndpointTest.getLists(bobsClient).get(0).getId()).isEqualTo(list.getId());
        assertThat(GetListItemsEndpointTest.getListItems(bobsClient, list)).isNotEmpty();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertBob.sql")
    @Sql("/InsertEve.sql")
    public void bobCanNotAddEveToAliceList() {
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(aliceClient);
        addUserToList(aliceClient, list, LoginTest.BOB_EMAIL);

        WebTestClient bobsClient = LoginTest.loginAsBob(webClient);
        requestAddUserToList(bobsClient, list, LoginTest.EVE_EMAIL).expectStatus().is4xxClientError();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void canNotAddUnknownUser() {
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(aliceClient);

        requestAddUserToList(aliceClient, list, "foo@bar.test").expectStatus().is4xxClientError();
    }
}
