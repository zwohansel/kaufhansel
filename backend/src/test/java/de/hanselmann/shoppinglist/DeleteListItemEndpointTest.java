package de.hanselmann.shoppinglist;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.reactive.server.WebTestClient;

import de.hanselmann.shoppinglist.restapi.dto.ShoppingListInfoDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemDto;
import de.hanselmann.shoppinglist.restapi.dto.ShoppingListItemUpdateDto;
import de.hanselmann.shoppinglist.testutils.WebServerTestWithTestUser;

@WebServerTestWithTestUser
public class DeleteListItemEndpointTest {

    private static final String PATH = "/api/shoppinglist/{id}/item/{itemId}";

    @Autowired
    private WebTestClient webClient;

    public static void deleteListItem(WebTestClient webClient,
            ShoppingListInfoDto list,
            ShoppingListItemDto item) {
        requestDeleteListItem(webClient, Long.valueOf(list.getId()), Long.valueOf(item.getId())).expectStatus()
                .is2xxSuccessful();
    }

    public static WebTestClient.ResponseSpec requestDeleteListItem(WebTestClient webClient,
            long listId,
            long itemId) {
        return webClient.delete().uri(PATH, listId, itemId).exchange();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    @Sql("/InsertTestItemIntoAliceList.sql")
    public void deleteExistingListItem() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);

        deleteListItem(client, list, item);

        assertThat(GetListItemsEndpointTest.getListItems(client, list)).isEmpty();
    }

    @Test
    @Sql("/InsertAliceList.sql")
    public void deleteItemItemThatIsNotPresentInList() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        requestDeleteListItem(client, Long.valueOf(list.getId()), 0).expectStatus().is2xxSuccessful();
    }

    @Test
    @Sql("/InsertBob.sql")
    @Sql("/InsertListOfBobSharedWithAliceAsReadOnly.sql")
    @Sql("/InsertTestItemIntoBobsList.sql")
    public void deleteItemFailsIfPermissionIsReadOnly() {
        WebTestClient client = LoginTest.loginAsAlice(webClient);
        ShoppingListInfoDto list = GetListsEndpointTest.getSingleList(client);
        ShoppingListItemDto item = GetListItemsEndpointTest.getSingleListItem(client, list);

        var updateItemDto = new ShoppingListItemUpdateDto();
        updateItemDto.setName("Updated Name");
        requestDeleteListItem(client, Long.valueOf(list.getId()), Long.valueOf(item.getId())).expectStatus()
                .is4xxClientError();

        ShoppingListItemDto updatedItem = GetListItemsEndpointTest.getSingleListItem(client, list);
        assertThat(updatedItem.getName()).as("Item name is unchanged.").isEqualTo(item.getName());
        assertThat(updatedItem.getCategory()).as("Item still has no category.").isNull();
        assertThat(updatedItem.isChecked()).as("Item is still unchecked.").isFalse();
    }
}
