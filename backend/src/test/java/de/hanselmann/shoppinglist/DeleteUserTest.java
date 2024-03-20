package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.LoginTest.LoggedInUser;
import de.hanselmann.shoppinglist.repository.ShoppingListRepository;
import de.hanselmann.shoppinglist.repository.ShoppingListUserRepository;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class DeleteUserTest {
    private static final String PATH = "/api/user/{userId}";

    @Autowired
    public ShoppingListUserRepository userRepository;

    @Autowired
    public ShoppingListRepository listRepository;

    @Autowired
    private WebTestClient webClient;

    public static void deleteUser(WebTestClient webClient, long userId) {
        requestDeleteUser(webClient, userId)
                .expectStatus()
                .is2xxSuccessful();
    }

    private static ResponseSpec requestDeleteUser(WebTestClient webClient, long userId) {
        return webClient.delete()
                .uri(PATH, userId)
                .exchange();
    }

    @Test
    public void canDeleteUser() {
        LoggedInUser user = LoginTest.loginAsAliceWithInfo(webClient);
        deleteUser(user.client, Long.valueOf(user.info.getId()));
        // Assert that the user is actually deleted in compliance with GDPR
        assertThat(userRepository.findAll()).isEmpty();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void deletingUserDeletesPrivateLists() {
        LoggedInUser user = LoginTest.loginAsAliceWithInfo(webClient);
        deleteUser(user.client, Long.valueOf(user.info.getId()));
        // Assert that the lists of the user which are not shared with anyone
        // else are deleted in compliance with GDPR
        assertThat(listRepository.findAll()).isEmpty();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsAdmin.sql")
    public void sharedListIsNotDeletedIfAnotherAdminIsPresent() {
        LoggedInUser bob = LoginTest.loginAsBobWithInfo(webClient);
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        // Delete admin bob
        deleteUser(bob.client, Long.valueOf(bob.info.getId()));

        // Assert that alice can still fetch the list...
        ShoppingListInfoDto aliceListInfo = GetListsEndpointTest.getSingleList(aliceClient);
        // ...and is now the only user
        assertThat(aliceListInfo.getOtherUsers()).isEmpty();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadWrite.sql")
    public void sharedListIsDeletedIfNoOtherAdminIsPresent() {
        LoggedInUser bob = LoginTest.loginAsBobWithInfo(webClient);
        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        // Delete admin bob
        deleteUser(bob.client, Long.valueOf(bob.info.getId()));
        // Assert that alice can no longer fetch the list...
        assertThat(GetListsEndpointTest.getLists(aliceClient)).isEmpty();
    }

    @Test
    @Sql("/InsertEve.sql")
    public void userCannotBeDeletedByOtherUser() {
        LoggedInUser alice = LoginTest.loginAsAliceWithInfo(webClient);
        WebTestClient eve = LoginTest.loginAsEve(webClient);

        requestDeleteUser(eve, Long.valueOf(alice.info.getId())).expectStatus().isForbidden();
    }
}
