package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class RemoveUserFromListTest {
    private static final String PATH = "/api/shoppinglist/{id}/user/{userId}";

    @Autowired
    private WebTestClient webClient;

    public static void removeUserFromList(WebTestClient webClient, ShoppingListInfoDto list,
            long userId) {
        requestRemoveUserFromList(webClient, list, userId)
                .expectStatus()
                .is2xxSuccessful();
    }

    private static ResponseSpec requestRemoveUserFromList(WebTestClient webClient, ShoppingListInfoDto list,
            long userId) {
        return webClient.delete()
                .uri(PATH, list.getId(), userId)
                .exchange();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    public void removedCanNotSeeList() {
        WebTestClient bobClient = LoginTest.loginAsBob(webClient);
        ShoppingListInfoDto bobListInfo = GetListsEndpointTest.getSingleList(bobClient);

        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto aliceListInfo = GetListsEndpointTest.getSingleList(aliceClient);

        assertThat(bobListInfo.getId()).isEqualTo(aliceListInfo.getId());
        assertThat(bobListInfo.getOtherUsers()).hasSize(1);
        assertThat(bobListInfo.getOtherUsers().get(0).getUserEmailAddress()).isEqualTo(LoginTest.ALICE_EMAIL);
        long aliceId = bobListInfo.getOtherUsers().get(0).getUserId();

        // Remove Alice from the list
        removeUserFromList(bobClient, bobListInfo, aliceId);

        // Alice should no longer be able to see the list...
        assertThat(GetListsEndpointTest.getLists(aliceClient)).isEmpty();
        // ...or read from it
        GetListItemsEndpointTest.requestListItems(aliceClient, aliceListInfo).expectStatus().is4xxClientError();
    }
}
