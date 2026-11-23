package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.client.RestTestClient;
import org.springframework.test.web.servlet.client.RestTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListNameUpdateDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class ChangeShoppingListNameTest {
    private static final String PATH = "/api/shoppinglist/{id}/name";

    @Autowired
    private RestTestClient webClient;

    public static void changeListName(RestTestClient webClient, ShoppingListInfoDto list, String newName) {
        requestChangeListName(webClient, list, newName).expectStatus().is2xxSuccessful();
    }

    private static ResponseSpec requestChangeListName(RestTestClient webClient,
            ShoppingListInfoDto list,
            String newName) {
        ShoppingListNameUpdateDto changeNameDto = new ShoppingListNameUpdateDto();
        changeNameDto.setName(newName);
        return webClient.put()
                .uri(PATH, list.getId())
                .body(changeNameDto)
                .exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void canRenameListWithAdminPermission() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        changeListName(client, list, "foobar");

        assertThat(GetListsEndpointTest.getSingleList(client).getName()).isEqualTo("foobar");
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadWrite.sql")
    public void canNotRenameListWithReadWritePermission() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        requestChangeListName(client, list, "foobar").expectStatus().is4xxClientError();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsCheckOnly.sql")
    public void canNotRenameListWithCheckOnlyPermission() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        requestChangeListName(client, list, "foobar").expectStatus().is4xxClientError();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    public void canNotRenameListWithReadOnlyPermission() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        requestChangeListName(client, list, "foobar").expectStatus().is4xxClientError();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void canNotRenameToEmptyString() {
        RestTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);

        requestChangeListName(client, list, "").expectStatus().is4xxClientError();
    }

}
