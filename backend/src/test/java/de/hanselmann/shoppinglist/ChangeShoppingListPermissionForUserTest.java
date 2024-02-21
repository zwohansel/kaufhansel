package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.reactive.server.WebTestClient.ResponseSpec;

import de.hanselmann.shoppinglist.model.ShoppingListRole;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListPermissionsUpdateDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class ChangeShoppingListPermissionForUserTest {
    private static final String PATH = "/api/shoppinglist/{id}/permissions";

    @Autowired
    private WebTestClient webClient;

    public static void changeUserPermission(WebTestClient webClient, ShoppingListInfoDto list,
            ShoppingListPermissionsUpdateDto permissionDto) {
        requestChangeUserPermission(webClient, list, permissionDto)
                .expectStatus()
                .is2xxSuccessful();
    }

    private static ResponseSpec requestChangeUserPermission(WebTestClient webClient, ShoppingListInfoDto list,
            ShoppingListPermissionsUpdateDto permissionDto) {
        return webClient.put()
                .uri(PATH, list.getId())
                .bodyValue(permissionDto)
                .exchange();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    @Sql("/InsertTestItemIntoBobsList.sql")
    public void elevateAliceFromReadOnlyToCheckOnly() {
        WebTestClient bobClient = LoginTest.loginAsBob(webClient);
        ShoppingListInfoDto bobListInfo = GetListsEndpointTest.getSingleList(bobClient);

        WebTestClient aliceClient = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto aliceListInfo = GetListsEndpointTest.getSingleList(aliceClient);

        // Alice should not be able to uncheck all list items
        UncheckListItemsEndpointTest.requestUncheckAllItems(aliceClient, aliceListInfo)
                .expectStatus()
                .is4xxClientError();

        assertThat(bobListInfo.getId()).isEqualTo(aliceListInfo.getId());
        assertThat(bobListInfo.getOtherUsers()).hasSize(1);
        assertThat(bobListInfo.getOtherUsers().get(0).getUserEmailAddress()).isEqualTo(LoginTest.ALICE_EMAIL);
        long aliceId = bobListInfo.getOtherUsers().get(0).getUserId();

        // Change alice permission from read-only to check-only
        ShoppingListPermissionsUpdateDto permissionDto = new ShoppingListPermissionsUpdateDto();
        permissionDto.setUserId(aliceId);
        permissionDto.setRole(ShoppingListRole.CHECK_ONLY);
        changeUserPermission(bobClient, bobListInfo, permissionDto);

        // Alice should now be able to uncheck all items
        UncheckListItemsEndpointTest.requestUncheckAllItems(aliceClient, aliceListInfo)
                .expectStatus()
                .is2xxSuccessful();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    @Sql("/InsertTestItemIntoBobsList.sql")
    public void canNotRevokeAdminRole() {
        WebTestClient bobClient = LoginTest.loginAsBob(webClient);
        ShoppingListInfoDto bobListInfo = GetListsEndpointTest.getSingleList(bobClient);

        assertThat(bobListInfo.getOtherUsers()).hasSize(1);
        assertThat(bobListInfo.getOtherUsers().get(0).getUserEmailAddress()).isEqualTo(LoginTest.ALICE_EMAIL);
        long aliceId = bobListInfo.getOtherUsers().get(0).getUserId();

        // Change alice permission from read-only to admin
        ShoppingListPermissionsUpdateDto permissionDto = new ShoppingListPermissionsUpdateDto();
        permissionDto.setUserId(aliceId);
        permissionDto.setRole(ShoppingListRole.ADMIN);
        changeUserPermission(bobClient, bobListInfo, permissionDto);

        // It should not be possible to change alice's role again
        permissionDto.setRole(ShoppingListRole.READ_WRITE);
        requestChangeUserPermission(bobClient, bobListInfo, permissionDto).expectStatus().is4xxClientError();

        permissionDto.setRole(ShoppingListRole.CHECK_ONLY);
        requestChangeUserPermission(bobClient, bobListInfo, permissionDto).expectStatus().is4xxClientError();

        permissionDto.setRole(ShoppingListRole.READ_ONLY);
        requestChangeUserPermission(bobClient, bobListInfo, permissionDto).expectStatus().is4xxClientError();
    }
}
